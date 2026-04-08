/**
        Smoked Token Burn - $BURN
        Telegram: https://t.me/SmokedTokenBurn
        Twitter: https://twitter.com/SmokedTokenBurn
        Website: https://SmokedTokenBurn.com
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract nameFacet is IERC20, IERC20Metadata, Context, Ownable {
    event SetFee(uint256 value);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function name() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
    function symbol() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tTotalSupply;
    }
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rate = _getRate();
        return ds._rBalances[account] / rate;
    }
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    function allowance(
        address account,
        address spender
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[account][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function setFee(uint256 newTxFee) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxFee = newTxFee;
        emit SetFee(ds.taxFee);
    }
    function excludeFromReward(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isExcludedFromReward[account], "Address already excluded");
        require(
            ds._excludedFromReward.length < 100,
            "Excluded list is too long"
        );

        if (ds._rBalances[account] > 0) {
            uint256 rate = _getRate();
            ds._tBalances[account] = ds._rBalances[account] / rate;
        }
        ds.isExcludedFromReward[account] = true;
        ds._excludedFromReward.push(account);
    }
    function includeInReward(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.isExcludedFromReward[account],
            "Account is already included"
        );
        uint256 nExcluded = ds._excludedFromReward.length;
        for (uint256 i = 0; i < nExcluded; i++) {
            if (ds._excludedFromReward[i] == account) {
                ds._excludedFromReward[i] = ds._excludedFromReward[
                    ds._excludedFromReward.length - 1
                ];
                ds._tBalances[account] = 0;
                ds.isExcludedFromReward[account] = false;
                ds._excludedFromReward.pop();
                break;
            }
        }
    }
    function excludeFromFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFee[account] = false;
    }
    function withdrawTokens(
        address tokenAddress,
        address receiverAddress
    ) external onlyOwner returns (bool success) {
        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 amount = tokenContract.balanceOf(address(this));
        return tokenContract.transfer(receiverAddress, amount);
    }
    function withdrawStuckETH() public onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
    function withdrawStuckTokens(address tkn) public onlyOwner {
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint256 amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive, "Trading already active.");

        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());

        _approve(address(this), address(ds.uniswapV2Pair), ds._tTotalSupply);

        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint256).max
        );

        _setAutomatedMarketMakerPair(address(ds.uniswapV2Pair), true);

        uint256 tokensInWallet = balanceOf(address(this));
        uint256 tokensToAdd = (tokensInWallet * 100) / 100; // 69% of tokens in contract go to LP

        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokensToAdd,
            0,
            0,
            owner(),
            block.timestamp
        );

        ds.tradingActive = true;
        ds.swapEnabled = true;
    }
    function _approve(
        address account,
        address spender,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[account][spender] = amount;
        emit Approval(account, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            allowance(msg.sender, spender) + addedValue
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _spendAllowance(
        address account,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(account, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(account, spender, currentAllowance - amount);
            }
        }
    }
    function _swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        bool success;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 20) {
            contractBalance = ds.swapTokensAtAmount * 20;
        }

        _swapTokensForEth(contractBalance);

        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            emit Transfer(from, to, 0);
            return;
        }

        if (!ds.tradingActive) {
            require(
                ds.isExcludedFromFee[from] || ds.isExcludedFromFee[to],
                "ERC20: Trading is not active."
            );
        }

        if (
            ds.marketingBalance > ds.swapTokensAtAmount &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds.isExcludedFromFee[from] &&
            !ds.isExcludedFromFee[to] &&
            !ds.swapping
        ) {
            ds.swapping = true;

            _swapBack();

            ds.swapping = false;
        }

        uint256 _taxFee = 0;
        uint256 _marketingTaxFee = 0;

        // on buy
        if (ds.automatedMarketMakerPairs[from] && !ds.isExcludedFromFee[to]) {
            _taxFee = ds.taxFee;
            _marketingTaxFee = ds._marketingBuyTax;

            if (ds._buyCount <= ds._reduceBuyTaxAt) {
                _marketingTaxFee = ds._initialMarketingBuyTax;
            }

            if (amount >= ds._whaleThreshold) {
                _marketingTaxFee = ds._antiWhaleBuyTax;
            }

            ds._buyCount++;

            // on sell
        } else if (
            ds.automatedMarketMakerPairs[to] && !ds.isExcludedFromFee[from]
        ) {
            _taxFee = ds.taxFee;
            _marketingTaxFee = ds._marketingSellTax;

            if (ds._sellCount <= ds._reduceSellTaxAt) {
                _marketingTaxFee = ds._initialMarketingSellTax;
            }

            if (amount >= ds._whaleThreshold) {
                _marketingTaxFee = ds._antiWhaleSellTax;
            }

            ds._sellCount++;
        }

        if (ds.isExcludedFromFee[from] || ds.isExcludedFromFee[to]) {
            _taxFee = 0;
            _marketingTaxFee = 0;
        }

        // calc t-values
        uint256 tTxFee = (amount * _taxFee) / 10000;
        uint256 tMarketingFee = (amount * _marketingTaxFee) / 10000;
        uint256 tTransferAmount = amount - tTxFee - tMarketingFee;

        // calc r-values
        uint256 rTxFee = (tTxFee + tMarketingFee) * _getRate();
        uint256 rAmount = amount * _getRate();
        uint256 rTransferAmount = rAmount - rTxFee;

        if (tMarketingFee > 0) {
            ds.marketingBalance = ds.marketingBalance + tMarketingFee;

            _liquify(tMarketingFee);

            emit Transfer(from, address(this), tMarketingFee);
        }

        if (ds.isExcludedFromReward[from]) {
            require(
                ds._tBalances[from] >= amount,
                "ERC20: transfer amount exceeds balance"
            );
        } else {
            require(
                ds._rBalances[from] >= rAmount,
                "ERC20: transfer amount exceeds balance"
            );
        }

        // Overflow not possible: the sum of all balances is capped by
        // rTotalSupply and tTotalSupply, and the sum is preserved by
        // decrementing then incrementing.
        unchecked {
            // udpate balances in r-space
            ds._rBalances[from] -= rAmount;
            ds._rBalances[to] += rTransferAmount;

            // update balances in t-space
            if (ds.isExcludedFromReward[from] && ds.isExcludedFromReward[to]) {
                ds._tBalances[from] -= amount;
                ds._tBalances[to] += tTransferAmount;
            } else if (
                ds.isExcludedFromReward[from] && !ds.isExcludedFromReward[to]
            ) {
                // could technically underflow but because tAmount is a
                // function of rAmount and ds._rTotalSupply == ds._tTotalSupply
                // it won't
                ds._tBalances[from] -= amount;
            } else if (
                !ds.isExcludedFromReward[from] && ds.isExcludedFromReward[to]
            ) {
                // could technically overflow but because tAmount is a
                // function of rAmount and ds._rTotalSupply == ds._tTotalSupply
                // it won't
                ds._tBalances[to] += tTransferAmount;
            }

            // reflect fee
            // can never go below zero because rTxFee percentage of
            // current ds._rTotalSupply
            ds._rTotalSupply = ds._rTotalSupply - rTxFee;
            ds.totalFees += tTxFee;
        }

        emit Transfer(from, to, tTransferAmount);
    }
    function _getRate() private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rSupply = ds._rTotalSupply;
        uint256 tSupply = ds._tTotalSupply;

        uint256 nExcluded = ds._excludedFromReward.length;
        for (uint256 i = 0; i < nExcluded; i++) {
            rSupply = rSupply - ds._rBalances[ds._excludedFromReward[i]];
            tSupply = tSupply - ds._tBalances[ds._excludedFromReward[i]];
        }
        if (rSupply < ds._rTotalSupply / ds._tTotalSupply) {
            rSupply = ds._rTotalSupply;
            tSupply = ds._tTotalSupply;
        }
        // rSupply always > tSupply (no precision loss)
        uint256 rate = rSupply / tSupply;
        return rate;
    }
    function _liquify(uint256 tLiquidity) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rLiquidity = tLiquidity * _getRate();
        ds._rBalances[address(this)] += rLiquidity;
        if (ds.isExcludedFromReward[address(this)]) {
            ds._tBalances[address(this)] += tLiquidity;
        }
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
