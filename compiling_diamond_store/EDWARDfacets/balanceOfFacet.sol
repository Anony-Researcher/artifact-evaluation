/**

Edward Paperhands - HODL

Links below:

https://edwardpaperhands.lol/

https://twitter.com/Edward_Paperhan

https://t.me/edwardpaperhandsportal

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;
import "./TestLib.sol";
contract balanceOfFacet is IERC20, Context, Ownable {
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balance[account];
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
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function enableTrade() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.launch = 1;
        ds.launchBlock = block.number;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTxAmount = _totalSupply;
    }
    function excludeAddressFromFees(address wallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFeeWallet[wallet] = true;
    }
    function setNewFeeAmount(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newBuyTax < 150, "Cannot set buy tax greater than 15%");
        ds.buyTax = newBuyTax;
        require(newSellTax < 150, "Cannot set sell tax greater than 15%");
        ds.sellTax = newSellTax;
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
            ds._allowances[sender][_msgSender()] - amount
        );
        return true;
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 1e9, "Min transfer amt");

        uint256 _tax;
        if (
            ds._isExcludedFromFeeWallet[from] || ds._isExcludedFromFeeWallet[to]
        ) {
            _tax = 0;
        } else {
            require(
                ds.launch != 0 && amount <= ds.maxTxAmount,
                "Launch / Max TxAmount 1% at ds.launch"
            );

            if (ds.inSwapAndLiquify == 1) {
                //No tax transfer
                ds._balance[from] -= amount;
                ds._balance[to] += amount;

                emit Transfer(from, to, amount);
                return;
            }

            if (from == ds.uniswapV2Pair) {
                _tax = ds.buyTax;
            } else if (to == ds.uniswapV2Pair) {
                uint256 tokensToSwap = ds._balance[address(this)];
                if (tokensToSwap > minSwap && ds.inSwapAndLiquify == 0) {
                    if (tokensToSwap > onePercent) {
                        tokensToSwap = onePercent;
                    }
                    ds.inSwapAndLiquify = 1;
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = ds.WETH;
                    ds
                        .uniswapV2Router
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            tokensToSwap,
                            0,
                            path,
                            ds.marketingWallet,
                            block.timestamp
                        );
                    ds.inSwapAndLiquify = 0;
                }
                _tax = ds.sellTax;
            } else {
                _tax = 0;
            }
        }

        //Is there tax for sender|receiver?
        if (_tax != 0) {
            //Tax transfer
            uint256 taxTokens = (amount * _tax) / 100;
            uint256 transferAmount = amount - taxTokens;

            ds._balance[from] -= amount;
            ds._balance[to] += transferAmount;
            ds._balance[address(this)] += taxTokens;
            emit Transfer(from, address(this), taxTokens);
            emit Transfer(from, to, transferAmount);
        } else {
            //No tax transfer
            ds._balance[from] -= amount;
            ds._balance[to] += amount;

            emit Transfer(from, to, amount);
        }
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
