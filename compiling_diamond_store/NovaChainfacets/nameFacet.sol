/**

Welcome to Nova Chain

Nova Chain revolutionizes blockchain technology by integrating AI with a Proof of Authority (PoA) consensus mechanism, fostering rapid block times and minimal transaction fees.

Telegram: https://t.me/novachain_portal
Website: https://novachain.space/
Chain Explorer: https://novaexplorer.org/
Docs: https://docs.novachain.space/
X: https://twitter.com/TheNovaChain

Name : Nova Testnet
Symbol: tNova
Chain ID : 76
RPC: https://rpc.novaexplorer.org
Explorer : https://novaexplorer.org

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;
import "./TestLib.sol";
contract nameFacet is IERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function startTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingAllowed = true;
    }
    function getOwner() external view override returns (address) {
        return owner;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function setisExempt(address _address, bool _enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[_address] = _enabled;
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }
    function setContractSwapSettings(
        uint256 _swapAmount,
        uint256 _swapThreshold,
        uint256 _minTokenAmount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapAmount = _swapAmount;
        ds.swapThreshold = ds._totalSupply.mul(_swapThreshold).div(
            uint256(100000)
        );
        ds.minTokenAmount = ds._totalSupply.mul(_minTokenAmount).div(
            uint256(100000)
        );
    }
    function setTransactionRequirements(
        uint256 _liquidity,
        uint256 _marketing,
        uint256 _burn,
        uint256 _development,
        uint256 _total,
        uint256 _sell,
        uint256 _trans
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFee = _liquidity;
        ds.marketingFee = _marketing;
        ds.burnFee = _burn;
        ds.developmentFee = _development;
        ds.totalFee = _total;
        ds.sellFee = _sell;
        ds.transferFee = _trans;
        require(
            ds.totalFee <= ds.denominator.div(1) &&
                ds.sellFee <= ds.denominator.div(1) &&
                ds.transferFee <= ds.denominator.div(1),
            "ds.totalFee and ds.sellFee cannot be more than 20%"
        );
    }
    function setTransactionLimits(
        uint256 _buy,
        uint256 _sell,
        uint256 _wallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 newTx = ds._totalSupply.mul(_buy).div(10000);
        uint256 newTransfer = ds._totalSupply.mul(_sell).div(10000);
        uint256 newWallet = ds._totalSupply.mul(_wallet).div(10000);
        ds._maxTxAmount = newTx;
        ds._maxSellAmount = newTransfer;
        ds._maxWalletToken = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(
            newTx >= limit && newTransfer >= limit && newWallet >= limit,
            "Max TXs and Max Wallet cannot be less than .5%"
        );
    }
    function setInternalAddresses(
        address _marketing,
        address _liquidity,
        address _development
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketing_receiver = _marketing;
        ds.liquidity_receiver = _liquidity;
        ds.development_receiver = _development;
        ds.isFeeExempt[_marketing] = true;
        ds.isFeeExempt[_liquidity] = true;
        ds.isFeeExempt[_development] = true;
    }
    function manualSwap() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amount = balanceOf(address(this));
        if (amount > ds.swapThreshold) {
            amount = ds.swapThreshold;
        }
        swapAndLiquify(amount);
    }
    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(ds.development_receiver, _amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            ds._allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            amount <= balanceOf(sender),
            "You are trying to transfer more than your balance"
        );
        if (!ds.isFeeExempt[sender] && !ds.isFeeExempt[recipient]) {
            require(ds.tradingAllowed, "ds.tradingAllowed");
        }
        if (
            !ds.isFeeExempt[sender] &&
            !ds.isFeeExempt[recipient] &&
            recipient != address(ds.pair) &&
            recipient != address(DEAD)
        ) {
            require(
                (ds._balances[recipient].add(amount)) <= ds._maxWalletToken,
                "Exceeds maximum wallet amount."
            );
        }
        if (sender != ds.pair) {
            require(
                amount <= ds._maxSellAmount ||
                    ds.isFeeExempt[sender] ||
                    ds.isFeeExempt[recipient],
                "TX Limit Exceeded"
            );
        }
        require(
            amount <= ds._maxTxAmount ||
                ds.isFeeExempt[sender] ||
                ds.isFeeExempt[recipient],
            "TX Limit Exceeded"
        );
        if (recipient == ds.pair && !ds.isFeeExempt[sender]) {
            ds.swapTimes += uint256(1);
        }
        if (shouldContractSwap(sender, recipient, amount)) {
            swapAndLiquify(ds.swapThreshold);
            ds.swapTimes = uint256(0);
        }
        ds._balances[sender] = ds._balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, amount)
            : amount;
        ds._balances[recipient] = ds._balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (getTotalFee(sender, recipient) > 0) {
            uint256 feeAmount = amount.div(ds.denominator).mul(
                getTotalFee(sender, recipient)
            );
            ds._balances[address(this)] = ds._balances[address(this)].add(
                feeAmount
            );
            emit Transfer(sender, address(this), feeAmount);
            if (
                ds.burnFee > uint256(0) &&
                getTotalFee(sender, recipient) > ds.burnFee
            ) {
                _transfer(
                    address(this),
                    address(DEAD),
                    amount.div(ds.denominator).mul(ds.burnFee)
                );
            }
            return amount.sub(feeAmount);
        }
        return amount;
    }
    function getTotalFee(
        address sender,
        address recipient
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isBot[sender] || ds.isBot[recipient]) {
            return ds.denominator.sub(uint256(100));
        }
        if (recipient == ds.pair) {
            return ds.sellFee;
        }
        if (sender == ds.pair) {
            return ds.totalFee;
        }
        return ds.transferFee;
    }
    function shouldContractSwap(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool aboveMin = amount >= ds.minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= ds.swapThreshold;
        return
            !ds.swapping &&
            ds.swapEnabled &&
            ds.tradingAllowed &&
            aboveMin &&
            !ds.isFeeExempt[sender] &&
            recipient == ds.pair &&
            ds.swapTimes >= ds.swapAmount &&
            aboveThreshold;
    }
    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _denominator = (
            ds.liquidityFee.add(1).add(ds.marketingFee).add(ds.developmentFee)
        ).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(ds.liquidityFee).div(
            _denominator
        );
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance = deltaBalance.div(
            _denominator.sub(ds.liquidityFee)
        );
        uint256 ETHToAddLiquidityWith = unitBalance.mul(ds.liquidityFee);
        if (ETHToAddLiquidityWith > uint256(0)) {
            addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith);
        }
        uint256 marketingAmt = unitBalance.mul(2).mul(ds.marketingFee);
        if (marketingAmt > 0) {
            payable(ds.marketing_receiver).transfer(marketingAmt);
        }
        uint256 contractBalance = address(this).balance;
        if (contractBalance > uint256(0)) {
            payable(ds.development_receiver).transfer(contractBalance);
        }
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();
        _approve(address(this), address(ds.router), tokenAmount);
        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.router), tokenAmount);
        ds.router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            ds.liquidity_receiver,
            block.timestamp
        );
    }
    function shouldTakeFee(
        address sender,
        address recipient
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return !ds.isFeeExempt[sender] && !ds.isFeeExempt[recipient];
    }
}
