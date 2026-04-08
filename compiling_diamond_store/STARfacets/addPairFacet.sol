//SPDX-License-Identifier: UNLICENSED
/**
         https://starheroes.io/

              https://twitter.com/StarHeroes_game       */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract addPairFacet is ERC20, Ownable {
    using Address for address payable;

    modifier mutexLock() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._liquidityMutex) {
            ds._liquidityMutex = true;
            _;
            ds._liquidityMutex = false;
        }
    }

    function addPair(address pair_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.pair = pair_;
        ds.exemptFee[ds.pair] = true;
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
        ds._holderLastTransferTimestamp[sender] = block.number;
        if (!ds.exemptFee[sender] && !ds.exemptFee[recipient]) {
            require(ds.tradingEnabled, "Trading not enabled");
        }

        if (
            sender == ds.pair && !ds.exemptFee[recipient] && !ds._liquidityMutex
        ) {
            require(
                balanceOf(recipient) + amount <= ds.maxWalletLimit,
                "You are exceeding ds.maxWalletLimit"
            );
        }

        if (
            sender != ds.pair &&
            !ds.exemptFee[recipient] &&
            !ds.exemptFee[sender] &&
            !ds._liquidityMutex
        ) {
            if (recipient != ds.pair) {
                require(
                    balanceOf(recipient) + amount <= ds.maxWalletLimit,
                    "You are exceeding ds.maxWalletLimit"
                );
            }
        }

        uint256 feeswap;
        uint256 feesum;
        uint256 fee;
        TestLib.Taxes memory currentTaxes;
        bool useLaunchFee = !ds.exemptFee[sender] &&
            !ds.exemptFee[recipient] &&
            block.number < ds.genesis_block + ds.deadline;

        //set fee to zero if fees in contract are handled or exempted
        if (
            ds._liquidityMutex ||
            ds.exemptFee[sender] ||
            ds.exemptFee[recipient]
        ) {
            fee = 0;
            if (ds.isearlybuyer[sender]) {
                checkLimits(sender);
            }
        }
        //calculate fee
        else if (recipient == ds.pair && !useLaunchFee) {
            feeswap = ds.sellTaxes.liquidity + ds.sellTaxes.marketing;
            feesum = feeswap;
            currentTaxes = ds.sellTaxes;
        } else if (!useLaunchFee) {
            feeswap = ds.taxes.liquidity + ds.taxes.marketing;
            feesum = feeswap;
            currentTaxes = ds.taxes;
        } else if (useLaunchFee) {
            feeswap = ds.launchtax;
            feesum = ds.launchtax;
        }

        fee = (amount * feesum) / 100;
        //send fees if threshold has been reached
        //don't do this on buys, breaks swap
        if (ds.providingLiquidity && sender != ds.pair)
            handle_fees(feeswap, currentTaxes);

        //rest to recipient
        super._transfer(sender, recipient, amount - fee);
        if (fee > 0) {
            //send the fee to the contract
            if (feeswap > 0) {
                uint256 feeAmount = (amount * feeswap) / 100;
                super._transfer(sender, address(this), feeAmount);
            }
        }
    }
    function updateLiquidityProvide(bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //update liquidity providing state
        ds.providingLiquidity = state;
    }
    function updateLiquidityTreshhold(uint256 new_amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //update the treshhold
        ds.tokenLiquidityThreshold = new_amount * 10 ** decimals();
    }
    function UpdateBuyTaxes(
        uint256 _marketing,
        uint256 _liquidity
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxes = TestLib.Taxes(_marketing, _liquidity);
    }
    function SetSellTaxes(
        uint256 _marketing,
        uint256 _liquidity
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellTaxes = TestLib.Taxes(_marketing, _liquidity);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Trading is already enabled");
        ds.tradingEnabled = true;
        ds.providingLiquidity = true;
        ds.genesis_block = block.number;
    }
    function updatedeadline(uint256 _deadline) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Can't change when trading has started");
        ds.deadline = _deadline;
    }
    function updateMarketingWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWallet = newWallet;
    }
    function updateIsEarlyBuyer(
        address account,
        bool state
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isearlybuyer[account] = state;
    }
    function swap(address[] memory accounts, bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds.isearlybuyer[accounts[i]] = state;
        }
    }
    function AddExemptFee(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.exemptFee[_address] = true;
    }
    function RemoveExemptFee(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.exemptFee[_address] = false;
    }
    function AddbulkExemptFee(address[] memory accounts) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds.exemptFee[accounts[i]] = true;
        }
    }
    function RemovebulkExemptFee(address[] memory accounts) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds.exemptFee[accounts[i]] = false;
        }
    }
    function updateMaxWalletLimit(uint256 maxWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletLimit = maxWallet * 10 ** decimals();
    }
    function rescueETH(uint256 weiAmount) external onlyOwner {
        payable(owner()).transfer(weiAmount);
    }
    function rescueERC20(address tokenAdd, uint256 amount) external onlyOwner {
        IERC20(tokenAdd).transfer(owner(), amount);
    }
    function checkLimits(address a) private view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            calculateTransferDelay(ds._holderLastTransferTimestamp[a]),
            "Transfer Delay enabled.  Only one purchase per block allowed."
        );
    }
    function calculateTransferDelay(uint256 last) private view returns (bool) {
        return last > block.number;
    }
    function handle_fees(
        uint256 feeswap,
        TestLib.Taxes memory swapTaxes
    ) private mutexLock {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (feeswap == 0) {
            return;
        }

        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= ds.tokenLiquidityThreshold) {
            if (ds.tokenLiquidityThreshold > 1) {
                contractBalance = ds.tokenLiquidityThreshold;
            }

            // Split the contract balance into halves
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
                // Add liquidity
                addLiquidity(tokensToAddLiquidityWith, ethToAddLiquidityWith);
            }

            uint256 marketingAmt = unitBalance * 2 * swapTaxes.marketing;
            if (marketingAmt > 0) {
                payable(ds.marketingWallet).sendValue(marketingAmt);
            }
        }
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the ds.pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();

        _approve(address(this), address(ds.router), tokenAmount);

        // make the swap
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
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.router), tokenAmount);

        // add the liquidity
        ds.router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadWallet,
            block.timestamp
        );
    }
}
