/**


// Website: https://taora.xyz
// Telegram: https://t.me/BittensorOracle
// X: https://twitter.com/BittensorOracle
// Docs: https://docs.taora.xyz/

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
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
            _msgSender(),
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function setTrading(bool _tradingOpen) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = _tradingOpen;
    }
    function manualswap() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    function blockBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < bots_.length; i++) {
            ds.bots[bots_[i]] = true;
        }
    }
    function unblockBot(address notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bots[notbot] = false;
    }
    function airdrop(
        address[] calldata recipients,
        uint256[] calldata amount
    ) public onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            _transferNoTax(msg.sender, recipients[i], amount[i]);
        }
    }
    function transferOwnership(address newOwner) public override onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        ds._isExcludedFromFee[owner()] = false;
        _transferOwnership(newOwner);
        ds._isExcludedFromFee[owner()] = true;
    }
    function setFees(
        uint256 taxFeeOnBuy,
        uint256 taxFeeOnSell
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxFeeOnBuy = taxFeeOnBuy;
        ds._taxFeeOnSell = taxFeeOnSell;
    }
    function setMinSwapTokensThreshold(
        uint256 swapTokensAtAmount
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapTokensAtAmount = swapTokensAtAmount;
    }
    function toggleSwap(bool _swapEnabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = _swapEnabled;
    }
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = maxTxAmount;
    }
    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletSize = maxWalletSize;
    }
    function setIsFeeExempt(address holder, bool exempt) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[holder] = exempt;
    }
    function toggleTransferDelay() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelay = !ds.transferDelay;
    }
    function _transferNoTax(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        ds._balances[recipient] = ds._balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) {
            _transferNoTax(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (!ds._isExcludedFromFee[to] && !ds._isExcludedFromFee[from]) {
            require(ds.tradingOpen, "TOKEN: Trading not yet started");
            require(amount <= ds._maxTxAmount, "TOKEN: Max Transaction Limit");
            require(
                !ds.bots[from] && !ds.bots[to],
                "TOKEN: Your account is blacklisted!"
            );

            if (to != ds.uniswapV2Pair) {
                if (from == ds.uniswapV2Pair && ds.transferDelay) {
                    require(
                        ds._lastTX[tx.origin] + 3 minutes < block.timestamp &&
                            ds._lastTX[to] + 3 minutes < block.timestamp,
                        "TOKEN: 3 minutes cooldown between buys"
                    );
                }
                require(
                    balanceOf(to) + amount < ds._maxWalletSize,
                    "TOKEN: Balance exceeds wallet size!"
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= ds._swapTokensAtAmount;

            if (contractTokenBalance >= ds._swapTokensAtAmount) {
                contractTokenBalance = ds._swapTokensAtAmount;
            }

            if (
                canSwap &&
                !ds.inSwap &&
                from != ds.uniswapV2Pair &&
                ds.swapEnabled
            ) {
                swapTokensForEth(contractTokenBalance); // Reserve of 15% of tokens for liquidity
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0 ether) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        bool takeFee = true;

        //Transfer Tokens
        if (
            (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) ||
            (from != ds.uniswapV2Pair && to != ds.uniswapV2Pair)
        ) {
            takeFee = false;
        } else {
            //Set Fee for Buys
            if (from == ds.uniswapV2Pair && to != address(ds.uniswapV2Router)) {
                ds._taxFee = ds._taxFeeOnBuy;
            }

            //Set Fee for Sells
            if (to == ds.uniswapV2Pair && from != address(ds.uniswapV2Router)) {
                ds._taxFee = ds._taxFeeOnSell;
            }
        }
        ds._lastTX[tx.origin] = block.timestamp;
        ds._lastTX[to] = block.timestamp;
        _tokenTransfer(from, to, amount, takeFee);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethAmt = tokenAmount.mul(85).div(100);
        uint256 liqAmt = tokenAmount - ethAmt;
        uint256 balanceBefore = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            ethAmt,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountETH = address(this).balance.sub(balanceBefore);

        addLiquidity(liqAmt, amountETH.mul(15).div(100));
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // add the liquidity
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingAddress.transfer(amount);
    }
    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amountReceived = takeFees(sender, amount);
        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        ds._balances[recipient] = ds._balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
    function takeFees(
        address sender,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 feeAmount = amount.mul(ds._taxFee).div(100);
        ds._balances[address(this)] = ds._balances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
}
