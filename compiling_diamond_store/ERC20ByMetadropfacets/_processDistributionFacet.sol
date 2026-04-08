//
//          Telegram (not verified): https://t.me/Pepe2ERC20
//          Website  (not verified): https://pepe2eth.vip
//
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@                                                                                                @@
// @@   This token was launched using software provided by Metadrop. To learn more or to launch      @@
// @@   your own token, visit: https://metadrop.com. See legal info at the end of this file.         @@
// @@                                                                                                @@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//
// SPDX-License-Identifier: BUSL-1.1
// Metadrop Contracts (v2.1.0)
//

// Sources flattened with hardhat v2.17.2 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _processDistributionFacet is IERC20ByMetadrop, Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using SafeERC20 for IERC20;

    modifier onlyOwnerFactoryOrPool() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.metadropFactory != _msgSender() &&
            owner() != _msgSender() &&
            ds.driPool != _msgSender()
        ) {
            _revert(CallerIsNotFactoryProjectOwnerOrPool.selector);
        }
        if (owner() == _msgSender() && ds.driPool != address(0)) {
            _revert(CannotManuallyFundLPWhenUsingADRIPool.selector);
        }

        _;
    }
    modifier notDuringAutoswap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._autoSwapInProgress) {
            _revert(CannotPerformDuringAutoswap.selector);
        }
        _;
    }

    function _processDistribution(
        address[] memory recipients_,
        uint256[] memory amounts_
    ) internal returns (uint256 distributedSupply) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (recipients_.length != amounts_.length) {
            _revert(RecipientsAndAmountsMismatch.selector);
        }
        distributedSupply = 0;
        for (uint256 i = 0; i < recipients_.length; i++) {
            ds._unlimited.add(recipients_[i]);
            _mint(recipients_[i], amounts_[i] * (10 ** decimals()));
            distributedSupply += amounts_[i];
        }
        return distributedSupply;
    }
    function _mint(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (account == address(0)) {
            _revert(MintToZeroAddress.selector);
        }

        _beforeTokenTransfer(address(0), account, amount);

        ds._totalSupply += uint120(amount);
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            ds._balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _mintBalances(uint256 lpMint_, uint256 poolMint_) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (lpMint_ > 0) {
            _mint(address(this), lpMint_);
        }

        if (poolMint_ > 0) {
            _mint(ds.driPool, poolMint_);
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _transfer(
        address from,
        address to,
        uint256 amount,
        bool applyTax
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _beforeTokenTransfer(from, to, amount);

        // Perform pre-tax validation (e.g. amount doesn't exceed balance, max txn amount)
        uint256 fromBalance = _pretaxValidationAndLimits(from, to, amount);

        // Perform autoswap if eligible
        _autoSwap(from, to);

        uint256 amountMinusDeductions;

        // We limit the number of buys per tx.origin per block:
        if (isLiquidityPool(from)) {
            if (_blockMaxBuysPerOriginExceeded()) {
                _revert(MaxBuysPerBlockExceeded.selector);
            }
            ds._originBuysPerBlock[tx.origin][block.number] += 1;
        }

        // The first by from a liquidity pool is relevant for tokens that use an initial buy
        // type DRI pool, as the very first buy does not have tax or autoburn applied. In all
        // cases where this is NOT the initial buy, or where the initial buy is not relevant,
        // the processing is the same:
        if (_intialBuyTreatmentApplies(from)) {
            ds.initialBuyRelevantAndNotYetCompleted = false;
            amountMinusDeductions = amount;
        } else {
            // Process taxes
            amountMinusDeductions = _taxProcessing(applyTax, to, from, amount);

            // Process autoburn
            amountMinusDeductions = _autoburnProcessing(
                from,
                amount,
                amountMinusDeductions
            );
        }

        // Perform post-tax validation (e.g. total balance after post-tax amount applied)
        _posttaxValidationAndLimits(from, to, amountMinusDeductions);

        ds._balances[from] = fromBalance - amount;
        ds._balances[to] += amountMinusDeductions;

        emit Transfer(from, to, amountMinusDeductions);

        _afterTokenTransfer(from, to, amount);
    }
    function transfer(
        address to,
        uint256 amount
    ) public virtual override(IERC20) returns (bool) {
        address owner = _msgSender();
        _transfer(
            owner,
            to,
            amount,
            (isLiquidityPool(owner) || isLiquidityPool(to))
        );
        return true;
    }
    function _burnLiquidity(uint256 lpTokens_) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(ds.uniswapV2Pair).transfer(address(0), lpTokens_);

        emit LiquidityBurned(lpTokens_);
    }
    function _addInitialLiquidity(
        uint256 ethAmount_,
        uint256 vaultFee_
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Funded date is the date of first funding. We can only add initial liquidity once. If this date is set,
        // we cannot proceed
        if (ds.fundedDate != 0) {
            _revert(InitialLiquidityAlreadyAdded.selector);
        }

        ds.fundedDate = uint32(block.timestamp);
        ds.fundedBlock = uint32(block.number);

        // Can only do this if this contract holds tokens:
        if (balanceOf(address(this)) == 0) {
            _revert(NoTokenForLiquidityPair.selector);
        }

        // Approve the uniswap router for an inifinite amount (max uint256)
        // This means that we don't need to worry about later incrememtal
        // approvals on tax swaps, as the uniswap router allowance will never
        // be decreased (see code in decreaseAllowance for reference)
        _approve(address(this), address(ds._uniswapRouter), type(uint256).max);

        // Add the liquidity:
        (uint256 amountA, uint256 amountB, uint256 lpTokens) = ds
            ._uniswapRouter
            .addLiquidityETH{value: ethAmount_}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp
        );

        emit InitialLiquidityAdded(amountA, amountB, lpTokens);

        // We now set this to false so that future transactions can be eligibile for autoswaps
        ds._autoSwapInProgress = false;

        // Are we locking, or burning?
        if (ds.burnLPTokens) {
            _burnLiquidity(lpTokens);
        } else {
            // Lock the liquidity:
            _addLiquidityToVault(vaultFee_, lpTokens);
        }
    }
    function addInitialLiquidity(
        uint256 vaultFee_,
        uint256 lpLockupInDaysOverride_,
        bool burnLPTokensOverride_
    ) external payable onlyOwnerFactoryOrPool {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethForLiquidity;

        if ((ds.burnLPTokens == false) && (burnLPTokensOverride_ == true)) {
            ds.burnLPTokens = true;
        }

        if (ds.burnLPTokens) {
            if (msg.value == 0) {
                _revert(NoETHForLiquidityPair.selector);
            }
            ethForLiquidity = msg.value;
        } else {
            if (vaultFee_ >= msg.value) {
                // The amount of ETH MUST exceed the vault fee, otherwise what liquidity are we adding?
                _revert(NoETHForLiquidityPair.selector);
            }
            ethForLiquidity = msg.value - vaultFee_;
        }

        if (lpLockupInDaysOverride_ > ds.lpLockupInDays) {
            ds.lpLockupInDays = uint88(lpLockupInDaysOverride_);
        }

        _addInitialLiquidity(ethForLiquidity, vaultFee_);
    }
    function isLiquidityPool(address queryAddress_) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        /** @dev We check the ds.uniswapV2Pair address first as this is an immutable variable and therefore does not need
         * to be fetched from storage, saving gas if this address IS the uniswapV2Pool. We also add this address
         * to the enumerated set for ease of reference (for example it is returned in the getter), and it does
         * not add gas to any other calls, that still complete in 0(1) time.
         */
        return (queryAddress_ == ds.uniswapV2Pair ||
            ds._liquidityPools.contains(queryAddress_));
    }
    function liquidityPools()
        external
        view
        returns (address[] memory liquidityPools_)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._liquidityPools.values());
    }
    function addLiquidityPool(address newLiquidityPool_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Don't allow calls that didn't pass an address:
        if (newLiquidityPool_ == address(0)) {
            _revert(LiquidityPoolCannotBeAddressZero.selector);
        }
        // Only allow smart contract addresses to be added, as only these can be pools:
        if (newLiquidityPool_.code.length == 0) {
            _revert(LiquidityPoolMustBeAContractAddress.selector);
        }
        // Add this to the enumerated list:
        ds._liquidityPools.add(newLiquidityPool_);
        emit LiquidityPoolAdded(newLiquidityPool_);
    }
    function removeLiquidityPool(
        address removedLiquidityPool_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Remove this from the enumerated list:
        ds._liquidityPools.remove(removedLiquidityPool_);
        emit LiquidityPoolRemoved(removedLiquidityPool_);
    }
    function isUnlimited(address queryAddress_) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._unlimited.contains(queryAddress_));
    }
    function unlimitedAddresses()
        external
        view
        returns (address[] memory unlimitedAddresses_)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._unlimited.values());
    }
    function addUnlimited(address newUnlimited_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Add this to the enumerated list:
        ds._unlimited.add(newUnlimited_);
        emit UnlimitedAddressAdded(newUnlimited_);
    }
    function removeUnlimited(address removedUnlimited_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Remove this from the enumerated list:
        ds._unlimited.remove(removedUnlimited_);
        emit UnlimitedAddressRemoved(removedUnlimited_);
    }
    function isValidCaller(bytes32 queryHash_) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._validCallerCodeHashes.contains(queryHash_));
    }
    function validCallers()
        external
        view
        returns (bytes32[] memory validCallerHashes_)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._validCallerCodeHashes.values());
    }
    function addValidCaller(bytes32 newValidCallerHash_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._validCallerCodeHashes.add(newValidCallerHash_);
        emit ValidCallerAdded(newValidCallerHash_);
    }
    function removeValidCaller(
        bytes32 removedValidCallerHash_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Remove this from the enumerated list:
        ds._validCallerCodeHashes.remove(removedValidCallerHash_);
        emit ValidCallerRemoved(removedValidCallerHash_);
    }
    function setProjectTaxRecipient(
        address projectTaxRecipient_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.projectTaxRecipient = projectTaxRecipient_;
        emit ProjectTaxRecipientUpdated(projectTaxRecipient_);
    }
    function setSwapThresholdBasisPoints(
        uint16 swapThresholdBasisPoints_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.swapThresholdBasisPoints < MIN_AUTOSWAP_THRESHOLD_BP) {
            _revert(SwapThresholdTooLow.selector);
        }
        uint256 oldswapThresholdBasisPoints = ds.swapThresholdBasisPoints;
        ds.swapThresholdBasisPoints = swapThresholdBasisPoints_;
        emit AutoSwapThresholdUpdated(
            oldswapThresholdBasisPoints,
            swapThresholdBasisPoints_
        );
    }
    function setProjectTaxRates(
        uint16 newProjectBuyTaxBasisPoints_,
        uint16 newProjectSellTaxBasisPoints_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint16 oldBuyTaxBasisPoints = ds.projectBuyTaxBasisPoints;
        uint16 oldSellTaxBasisPoints = ds.projectSellTaxBasisPoints;
        // Cannot increase, down only
        if (newProjectBuyTaxBasisPoints_ > oldBuyTaxBasisPoints) {
            _revert(CanOnlyReduce.selector);
        }
        // Cannot increase, down only
        if (newProjectSellTaxBasisPoints_ > oldSellTaxBasisPoints) {
            _revert(CanOnlyReduce.selector);
        }
        ds.projectBuyTaxBasisPoints = newProjectBuyTaxBasisPoints_;
        ds.projectSellTaxBasisPoints = newProjectSellTaxBasisPoints_;

        // We set the metadrop tax rates off of the project tax rates:
        //
        // 1) If the project tax rate is zero then the metadrop tax rate is zero
        // 2) If the project tax rate is not zero the metadrop tax rate is the
        //    greater of:
        //    a) The metadrop tax proportion basis points of the project rate
        //    b) the base metadrop tax rate.
        //
        // Examples:
        //
        // A) The project buy tax rate is zero and the sell tax rate is 3%. The metadrop
        // tax proportion basis points is 1000, meaning the metadrop proportion is 10% of the
        // project tax rate. The base metadrop tax rate is 50 basis points i.e. 0.5%.
        //
        // * Metadrop buy tax = 0% (as the project buy tax is zero)
        // * Metadrop sell tax = 0.5%. 10% of the project sell tax is 0.3%. As this is below
        // the base level of 0.5% we set the metadrop tax to 0.5%
        //
        // B) The project buy tax rate is 4% and the sell tax rate is 20%. The metadrop tax
        // proportion basis points is 1000, meaning the metadrop proportion is 10% of the
        // project tax rate. The base metadrop tax rate is 50 basis points i.e. 0.5%.
        //
        // * Metadrop buy tax = 0.5%. 10% of the project rate would be 0.4%, so we use the base rate)
        // * Metadrop sell tax = 2%. 10% of the project rate is 2%, which is higher than the
        //   base rate of 0.5%.

        uint16 oldMetadropBuyTaxBasisPoints = ds.metadropBuyTaxBasisPoints;
        uint16 oldMetadropSellTaxBasisPoints = ds.metadropSellTaxBasisPoints;

        // Process the buy tax rate first:
        if (newProjectBuyTaxBasisPoints_ == 0) {
            ds.metadropBuyTaxBasisPoints = 0;
        } else {
            uint256 derivedMetadropBuyTaxRate = (newProjectBuyTaxBasisPoints_ *
                ds.metadropBuyTaxProportionBasisPoints) / BP_DENOM;
            if (derivedMetadropBuyTaxRate < ds.metadropMinBuyTaxBasisPoints) {
                ds.metadropBuyTaxBasisPoints = uint16(
                    ds.metadropMinBuyTaxBasisPoints
                );
            } else {
                ds.metadropBuyTaxBasisPoints = uint16(
                    derivedMetadropBuyTaxRate
                );
            }
        }

        // And now the sell tax rate:
        if (newProjectSellTaxBasisPoints_ == 0) {
            ds.metadropSellTaxBasisPoints = 0;
        } else {
            uint256 derivedMetadropSellTaxRate = (newProjectSellTaxBasisPoints_ *
                    ds.metadropSellTaxProportionBasisPoints) / BP_DENOM;
            if (derivedMetadropSellTaxRate < ds.metadropMinSellTaxBasisPoints) {
                ds.metadropSellTaxBasisPoints = uint16(
                    ds.metadropMinSellTaxBasisPoints
                );
            } else {
                ds.metadropSellTaxBasisPoints = uint16(
                    derivedMetadropSellTaxRate
                );
            }
        }

        // Emit a message if there has been a change:
        if (
            oldMetadropBuyTaxBasisPoints != ds.metadropBuyTaxBasisPoints ||
            oldMetadropSellTaxBasisPoints != ds.metadropSellTaxBasisPoints
        ) {
            emit MetadropTaxBasisPointsChanged(
                oldMetadropBuyTaxBasisPoints,
                ds.metadropBuyTaxBasisPoints,
                oldMetadropSellTaxBasisPoints,
                ds.metadropSellTaxBasisPoints
            );
        }

        emit ProjectTaxBasisPointsChanged(
            oldBuyTaxBasisPoints,
            newProjectBuyTaxBasisPoints_,
            oldSellTaxBasisPoints,
            newProjectSellTaxBasisPoints_
        );
    }
    function setLimits(
        uint256 newMaxTokensPerTransaction_,
        uint256 newMaxTokensPerWallet_
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (newMaxTokensPerWallet_ > type(uint120).max) {
            _revert(LimitTooHigh.selector);
        }

        if (newMaxTokensPerTransaction_ > type(uint120).max) {
            _revert(LimitTooHigh.selector);
        }

        uint256 oldMaxTokensPerTransaction = ds.maxTokensPerTransaction;
        uint256 oldMaxTokensPerWallet = ds.maxTokensPerWallet;
        // Limit can only be increased:
        if (
            (oldMaxTokensPerTransaction == 0 &&
                newMaxTokensPerTransaction_ != 0) ||
            (oldMaxTokensPerWallet == 0 && newMaxTokensPerWallet_ != 0)
        ) {
            _revert(LimitsCanOnlyBeRaised.selector);
        }
        if (
            ((newMaxTokensPerTransaction_ != 0) &&
                newMaxTokensPerTransaction_ < oldMaxTokensPerTransaction) ||
            ((newMaxTokensPerWallet_ != 0) &&
                newMaxTokensPerWallet_ < oldMaxTokensPerWallet)
        ) {
            _revert(LimitsCanOnlyBeRaised.selector);
        }

        ds.maxTokensPerTransaction = uint112(newMaxTokensPerTransaction_);
        ds.maxTokensPerWallet = uint120(newMaxTokensPerWallet_);

        emit LimitsUpdated(
            oldMaxTokensPerTransaction,
            newMaxTokensPerTransaction_,
            oldMaxTokensPerWallet,
            newMaxTokensPerWallet_
        );
    }
    function limitsEnforced() public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Limits are not enforced if
        // this is renounced AND after the protection end date
        // OR prior to LP funding:
        // The second clause of 'ds.fundedDate == 0' isn't strictly needed, since with a funded
        // date of 0 we would always expect the block.timestamp to be less than 0 plus
        // the ds.botProtectionDurationInSeconds. But, to cover the miniscule chance of a user
        // selecting a truly enormous bot protection period, such that when added to 0 it
        // is more than the current block.timestamp, we have included this second clause. There
        // is no permanent gas overhead (the logic will be returning from the first clause after
        // the bot protection period has expired). During the bot protection period there is a minor
        // gas overhead from evaluating the ds.fundedDate == 0 (which will be false), but this is minimal.
        if (
            (owner() == address(0) &&
                block.timestamp >
                ds.fundedDate + ds.botProtectionDurationInSeconds) ||
            ds.fundedDate == 0
        ) {
            return false;
        } else {
            // LP has been funded AND we are within the protection period:
            return true;
        }
    }
    function getMetadropBuyTaxBasisPoints() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // If we are outside the metadrop tax period this is ZERO
        if (
            block.timestamp >
            (ds.fundedDate + (ds.metadropTaxPeriodInDays * 1 days))
        ) {
            return 0;
        } else {
            return ds.metadropBuyTaxBasisPoints;
        }
    }
    function getMetadropSellTaxBasisPoints() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // If we are outside the metadrop tax period this is ZERO
        if (
            block.timestamp >
            (ds.fundedDate + (ds.metadropTaxPeriodInDays * 1 days))
        ) {
            return 0;
        } else {
            return ds.metadropSellTaxBasisPoints;
        }
    }
    function totalBuyTaxBasisPoints() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.projectBuyTaxBasisPoints + getMetadropBuyTaxBasisPoints();
    }
    function totalSellTaxBasisPoints() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.projectSellTaxBasisPoints + getMetadropSellTaxBasisPoints();
    }
    function distributeTaxTokens() external notDuringAutoswap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.projectTaxPendingSwap > 0) {
            uint256 projectDistribution = ds.projectTaxPendingSwap;
            ds.projectTaxPendingSwap = 0;
            _transfer(
                address(this),
                ds.projectTaxRecipient,
                projectDistribution,
                false
            );
        }

        if (ds.metadropTaxPendingSwap > 0) {
            uint256 metadropDistribution = ds.metadropTaxPendingSwap;
            ds.metadropTaxPendingSwap = 0;
            _transfer(
                address(this),
                ds.metadropTaxRecipient,
                metadropDistribution,
                false
            );
        }
    }
    function rescueETH(uint256 amount_) external notDuringAutoswap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (bool success, ) = ds.projectTaxRecipient.call{value: amount_}("");
        if (!success) {
            _revert(TransferFailed.selector);
        }
    }
    function rescueERC20(
        address token_,
        uint256 amount_
    ) external notDuringAutoswap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (token_ == address(this)) {
            _revert(CannotWithdrawThisToken.selector);
        }
        IERC20(token_).safeTransfer(ds.projectTaxRecipient, amount_);
    }
    function rescueExcessToken(uint256 amount_) external notDuringAutoswap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Cannot perform this before the token has been funded:
        if (ds.fundedDate == 0) {
            _revert(CannotPerformPriorToFunding.selector);
        }

        uint256 excessToken = balanceOf(address(this)) - totalTaxPendingSwap();

        if (amount_ > excessToken) {
            _revert(AmountExceedsAvailable.selector);
        }

        IERC20(address(this)).safeTransfer(ds.projectTaxRecipient, amount_);
    }
    function burn(uint256 value) public virtual {
        _burn(_msgSender(), value);
    }
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < amount) {
                _revert(InsufficientAllowance.selector);
            }

            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(
            from,
            to,
            amount,
            (isLiquidityPool(from) || isLiquidityPool(to))
        );
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (owner == address(0)) {
            _revert(ApproveFromTheZeroAddress.selector);
        }

        if (spender == address(0)) {
            _revert(ApproveToTheZeroAddress.selector);
        }

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function _addLiquidityToVault(
        uint256 vaultFee_,
        uint256 lpTokens_
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(ds.uniswapV2Pair).approve(address(ds._tokenVault), lpTokens_);

        ds._tokenVault.lockLPToken{value: vaultFee_}(
            ds.uniswapV2Pair,
            IERC20(ds.uniswapV2Pair).balanceOf(address(this)),
            block.timestamp + (ds.lpLockupInDays * 1 days),
            payable(address(0)),
            true,
            payable(ds.lpOwner)
        );

        emit LiquidityLocked(lpTokens_, ds.lpLockupInDays);
    }
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function _posttaxValidationAndLimits(
        address from_,
        address to_,
        uint256 amount_
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            limitsEnforced() &&
            (ds.maxTokensPerWallet != 0) &&
            !isUnlimited(to_) &&
            // If this is a buy (from a liquidity pool), we apply if the to_
            // address isn't noted as unlimited:
            (isLiquidityPool(from_) && !isUnlimited(to_))
        ) {
            // Liquidity pools aren't always going to round cleanly. This can (and does)
            // mean that a limit of 5,000 tokens (for example) will trigger on a max holding
            // of 5,000 tokens, as the transfer to achieve that is actually for
            // 5,000.00000000000000213. While 4,999 will work fine, it isn't hugely user friendly.
            // So we buffer the limit with rounding decimals, which in all cases are considerably
            // less than one whole token:
            uint256 roundedLimited;

            unchecked {
                roundedLimited = ds.maxTokensPerWallet + ROUND_DEC;
            }

            if ((amount_ + balanceOf(to_) > roundedLimited)) {
                _revert(MaxTokensPerWalletExceeded.selector);
            }
        }
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance < subtractedValue) {
            _revert(AllowanceDecreasedBelowZero.selector);
        }
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _burn(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (account == address(0)) {
            _revert(BurnFromTheZeroAddress.selector);
        }

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = ds._balances[account];
        if (accountBalance < amount) {
            _revert(BurnExceedsBalance.selector);
        }

        unchecked {
            ds._balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            ds._totalSupply -= uint120(amount);
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _autoburnProcessing(
        address from_,
        uint256 originalSentAmount_,
        uint256 currentRecipientAmount_
    ) internal returns (uint256 amountLessBurn_) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        amountLessBurn_ = currentRecipientAmount_;
        // Perform autoBurn processing, if appropriate:
        if (
            ds.autoBurnDurationInBlocks != 0 &&
            ds.autoBurnBasisPoints != 0 &&
            !ds._autoSwapInProgress &&
            isLiquidityPool(from_)
        ) {
            uint256 blocksElapsed = block.number - ds.fundedBlock;
            if (blocksElapsed < ds.autoBurnDurationInBlocks) {
                // Get the blocks remaining in the autoburn period. The more blocks
                // remaining, the higher the proportion of the burn we apply:
                uint256 burnBlocksRemaining = ds.autoBurnDurationInBlocks -
                    blocksElapsed;
                // Calculate the linear burn basis point per remaining block. For example, if our
                // burn basis points = 1500 (15%) and we are burning for three blocks then this
                // will be 1500 / 3 = 500 (5%):
                uint256 linearBurnPerRemainingBlock = ds.autoBurnBasisPoints /
                    ds.autoBurnDurationInBlocks;
                // Finally, determine the burn basis points for this block by multiplying the per remaining
                // block burn % by the number of blocks remaining. To follow our example, in the 0th
                // block since funding there are three blocks remaining in the burn period, therefore
                // 500 * 3 = 1500 (15%). Two blocks after funding we have one block remaining in the burn
                // period, and therefore are burning 500 * 1 = 500 (5%). Three blocks after funding we do not
                // reach this point in the logic, as the blocksElapsed is 3 and needs to be UNDER 3 to enter
                // this code.
                uint256 burnBasisPointsForThisBlock = burnBlocksRemaining *
                    linearBurnPerRemainingBlock;

                // This is eligible for burn. Send the basis points amount of
                // the originalSentAmount_ to the zero address:
                uint256 burnAmount = ((originalSentAmount_ *
                    burnBasisPointsForThisBlock) / BP_DENOM);

                _burn(from_, burnAmount);
                amountLessBurn_ -= burnAmount;
            }
        }
        return (amountLessBurn_);
    }
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function totalTaxPendingSwap() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.projectTaxPendingSwap + ds.metadropTaxPendingSwap;
    }
    function _autoSwap(address from_, address to_) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._tokenHasTax) {
            uint256 totalTaxBalance = totalTaxPendingSwap();
            uint256 swapBalance = totalTaxBalance;

            uint256 swapThresholdInTokens = (ds._totalSupply *
                ds.swapThresholdBasisPoints) / BP_DENOM;

            if (
                _eligibleForSwap(from_, to_, swapBalance, swapThresholdInTokens)
            ) {
                // Store that a swap back is in progress:
                ds._autoSwapInProgress = true;
                // Increment the swaps per block counter:
                ds._autoswapForBlock[block.number] += 1;
                // Check if we need to reduce the amount of tokens for this swap:
                if (
                    swapBalance >
                    swapThresholdInTokens * MAX_AUTOSWAP_THRESHOLD_MULTIPLE
                ) {
                    swapBalance =
                        swapThresholdInTokens *
                        MAX_AUTOSWAP_THRESHOLD_MULTIPLE;
                }
                // Perform the auto swap to native token:
                _swapTaxForNative(swapBalance, totalTaxBalance);
                // Flag that the autoswap is complete:
                ds._autoSwapInProgress = false;
            }
        }
    }
    function _eligibleForSwap(
        address from_,
        address to_,
        uint256 taxBalance_,
        uint256 swapThresholdInTokens_
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (taxBalance_ >= swapThresholdInTokens_ &&
            !ds._autoSwapInProgress &&
            !isLiquidityPool(from_) &&
            from_ != address(ds._uniswapRouter) &&
            to_ != address(ds._uniswapRouter) &&
            from_ != address(ds.driPool) &&
            ds._autoswapForBlock[block.number] < MAX_AUTOSWAPS_PER_BLOCK);
    }
    function _swapTaxForNative(
        uint256 swapBalance_,
        uint256 totalTaxBalance_
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 preSwapBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds._uniswapRouter.WETH();

        // Wrap external calls in try / catch to handle errors
        try
            ds
                ._uniswapRouter
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    swapBalance_,
                    0,
                    path,
                    address(this),
                    block.timestamp + 600
                )
        {
            uint256 postSwapBalance = address(this).balance;

            uint256 balanceToDistribute = postSwapBalance - preSwapBalance;

            uint256 projectBalanceToDistribute = (balanceToDistribute *
                ds.projectTaxPendingSwap) / totalTaxBalance_;

            uint256 metadropBalanceToDistribute = (balanceToDistribute *
                ds.metadropTaxPendingSwap) / totalTaxBalance_;

            // We will not have swapped all tax tokens IF the amount was greater than the max auto swap.
            // We therefore cannot just set the pending swap counters to 0. Instead, in this scenario,
            // we must reduce them in proportion to the swap amount vs the remaining balance + swap
            // amount.
            //
            // For example:
            //  * swap Balance is 250
            //  * contract balance is 385.
            //  * ds.projectTaxPendingSwap is 300
            //  * ds.metadropTaxPendingSwap is 85.
            //
            // The new total for the ds.projectTaxPendingSwap is:
            //   = 300 - ((300 * 250) / 385)
            //   = 300 - 194
            //   = 106
            // The new total for the ds.metadropTaxPendingSwap is:
            //   = 85 - ((85 * 250) / 385)
            //   = 85 - 55
            //   = 30
            //

            if (swapBalance_ < totalTaxBalance_) {
                // Calculate the project tax spending swap reduction amount:
                uint256 projectTaxPendingSwapReduction = (ds
                    .projectTaxPendingSwap * swapBalance_) / totalTaxBalance_;
                ds.projectTaxPendingSwap -= uint128(
                    projectTaxPendingSwapReduction
                );

                // The metadrop tax pending swap reduction is therefore the total swap amount minus the
                // project tax spending swap reduction:
                ds.metadropTaxPendingSwap -= uint128(
                    swapBalance_ - projectTaxPendingSwapReduction
                );
            } else {
                (ds.projectTaxPendingSwap, ds.metadropTaxPendingSwap) = (0, 0);
            }

            // Distribute to treasuries:
            bool success;
            address weth;
            uint256 gas;

            if (projectBalanceToDistribute > 0) {
                // If no gas limit was provided or provided gas limit greater than gas left, just use the remaining gas.
                gas = (CALL_GAS_LIMIT == 0 || CALL_GAS_LIMIT > gasleft())
                    ? gasleft()
                    : CALL_GAS_LIMIT;

                // We limit the gas passed so that a called address cannot cause a block out of gas error:
                (success, ) = ds.projectTaxRecipient.call{
                    value: projectBalanceToDistribute,
                    gas: gas
                }("");

                // If the ETH transfer fails, wrap the ETH and send it as WETH. We do this so that a called
                // address cannot cause this transfer to fail, either intentionally or by mistake:
                if (!success) {
                    if (weth == address(0)) {
                        weth = ds._uniswapRouter.WETH();
                    }

                    try
                        IWETH(weth).deposit{value: projectBalanceToDistribute}()
                    {
                        try
                            IERC20(address(weth)).transfer(
                                ds.projectTaxRecipient,
                                projectBalanceToDistribute
                            )
                        {} catch {
                            // Dont allow a failed external call (in this case to WETH) to stop a transfer.
                            // Emit that this has occured and continue.
                            emit ExternalCallError(1);
                        }
                    } catch {
                        // Dont allow a failed external call (in this case to WETH) to stop a transfer.
                        // Emit that this has occured and continue.
                        emit ExternalCallError(2);
                    }
                }
            }

            if (metadropBalanceToDistribute > 0) {
                // If no gas limit was provided or provided gas limit greater than gas left, just use the remaining gas.
                gas = (CALL_GAS_LIMIT == 0 || CALL_GAS_LIMIT > gasleft())
                    ? gasleft()
                    : CALL_GAS_LIMIT;

                (success, ) = ds.metadropTaxRecipient.call{
                    value: metadropBalanceToDistribute,
                    gas: gas
                }("");

                // If the ETH transfer fails, wrap the ETH and send it as WETH. We do this so that a called
                // address cannot cause this transfer to fail, either intentionally or by mistake:
                if (!success) {
                    if (weth == address(0)) {
                        weth = ds._uniswapRouter.WETH();
                    }
                    try
                        IWETH(weth).deposit{
                            value: metadropBalanceToDistribute
                        }()
                    {
                        try
                            IERC20(address(weth)).transfer(
                                ds.metadropTaxRecipient,
                                metadropBalanceToDistribute
                            )
                        {} catch {
                            // Dont allow a failed external call (in this case to WETH) to stop a transfer.
                            // Emit that this has occured and continue.
                            emit ExternalCallError(3);
                        }
                    } catch {
                        // Dont allow a failed external call (in this case to WETH) to stop a transfer.
                        // Emit that this has occured and continue.
                        emit ExternalCallError(4);
                    }
                }
            }
        } catch {
            // Dont allow a failed external call (in this case to uniswap) to stop a transfer.
            // Emit that this has occured and continue.
            emit ExternalCallError(5);
        }
    }
    function _taxProcessing(
        bool applyTax_,
        address to_,
        address from_,
        uint256 sentAmount_
    ) internal returns (uint256 amountLessTax_) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        amountLessTax_ = sentAmount_;
        if (ds._tokenHasTax && applyTax_ && !ds._autoSwapInProgress) {
            uint256 tax;

            // on sell
            if (isLiquidityPool(to_) && totalSellTaxBasisPoints() > 0) {
                if (ds.projectSellTaxBasisPoints > 0) {
                    uint256 projectTax = ((sentAmount_ *
                        ds.projectSellTaxBasisPoints) / BP_DENOM);
                    ds.projectTaxPendingSwap += uint128(projectTax);
                    tax += projectTax;
                }
                uint256 metadropSellTax = getMetadropSellTaxBasisPoints();
                if (metadropSellTax > 0) {
                    uint256 metadropTax = ((sentAmount_ * metadropSellTax) /
                        BP_DENOM);
                    ds.metadropTaxPendingSwap += uint128(metadropTax);
                    tax += metadropTax;
                }
            }
            // on buy
            else if (isLiquidityPool(from_) && totalBuyTaxBasisPoints() > 0) {
                if (ds.projectBuyTaxBasisPoints > 0) {
                    uint256 projectTax = ((sentAmount_ *
                        ds.projectBuyTaxBasisPoints) / BP_DENOM);
                    ds.projectTaxPendingSwap += uint128(projectTax);
                    tax += projectTax;
                }
                uint256 metadropBuyTax = getMetadropBuyTaxBasisPoints();
                if (metadropBuyTax > 0) {
                    uint256 metadropTax = ((sentAmount_ * metadropBuyTax) /
                        BP_DENOM);
                    ds.metadropTaxPendingSwap += uint128(metadropTax);
                    tax += metadropTax;
                }
            }

            if (tax > 0) {
                ds._balances[address(this)] += tax;
                emit Transfer(from_, address(this), tax);
                amountLessTax_ -= tax;
            }
        }
        return (amountLessTax_);
    }
    function _pretaxValidationAndLimits(
        address from_,
        address to_,
        uint256 amount_
    ) internal view returns (uint256 fromBalance_) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // This can't be a transfer to the liquidity pool before the funding date
        // UNLESS the from address is this contract. This ensures that the initial
        // LP funding transaction is from this contract using the supply of tokens
        // designated for the LP pool, and therefore the initial price in the pool
        // is being set as expected.
        //
        // This protects from, for example, tokens from a team minted supply being
        // paired with ETH and added to the pool, setting the initial price, BEFORE
        // the initial liquidity is added through this contract.
        if (
            to_ == ds.uniswapV2Pair &&
            from_ != address(this) &&
            ds.fundedDate == 0
        ) {
            _revert(InitialLiquidityNotYetAdded.selector);
        }

        if (from_ == address(0)) {
            _revert(TransferFromZeroAddress.selector);
        }

        if (to_ == address(0)) {
            _revert(TransferToZeroAddress.selector);
        }

        fromBalance_ = ds._balances[from_];

        if (fromBalance_ < amount_) {
            _revert(TransferAmountExceedsBalance.selector);
        }

        if (
            limitsEnforced() &&
            (ds.maxTokensPerTransaction != 0) &&
            ((isLiquidityPool(from_) && !isUnlimited(to_)) ||
                (isLiquidityPool(to_) && !isUnlimited(from_)))
        ) {
            // Liquidity pools aren't always going to round cleanly. This can (and does)
            // mean that a limit of 5,000 tokens (for example) will trigger on a transfer
            // of 5,000 tokens, as the transfer is actually for 5,000.00000000000000213.
            // While 4,999 will work fine, it isn't hugely user friendly. So we buffer
            // the limit with rounding decimals, which in all cases are considerably less
            // than one whole token:
            uint256 roundedLimited;

            unchecked {
                roundedLimited = ds.maxTokensPerTransaction + ROUND_DEC;
            }

            if (amount_ > roundedLimited) {
                _revert(MaxTokensPerTxnExceeded.selector);
            }
        }

        return (fromBalance_);
    }
    function _intialBuyTreatmentApplies(
        address from_
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            ds.initialBuyRelevantAndNotYetCompleted && isLiquidityPool(from_);
    }
    function _blockMaxBuysPerOriginExceeded() internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            ds._originBuysPerBlock[tx.origin][block.number] >=
            MAX_BUYS_PER_ORIGIN_PER_BLOCK;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function _processSupplyParams(
        ERC20SupplyParameters memory erc20SupplyParameters_,
        ERC20PoolParameters memory erc20PoolParameters_,
        uint256 distributedSupply_
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            erc20SupplyParameters_.maxSupply !=
            (erc20SupplyParameters_.ds.lpSupply +
                distributedSupply_ +
                erc20PoolParameters_.poolSupply)
        ) {
            _revert(SupplyTotalMismatch.selector);
        }

        if (erc20SupplyParameters_.maxSupply > type(uint120).max) {
            _revert(MaxSupplyTooHigh.selector);
        }

        if (erc20SupplyParameters_.ds.lpLockupInDays > type(uint88).max) {
            _revert(LPLockUpMustFitUint88.selector);
        }

        if (
            erc20SupplyParameters_.ds.botProtectionDurationInSeconds >
            type(uint128).max
        ) {
            _revert(botProtectionDurationInSecondsMustFitUint128.selector);
        }

        if (erc20SupplyParameters_.ds.maxTokensPerWallet > type(uint120).max) {
            _revert(LimitTooHigh.selector);
        }

        if (erc20SupplyParameters_.maxTokensPerTxn > type(uint120).max) {
            _revert(LimitTooHigh.selector);
        }

        ds.maxTokensPerWallet = uint120(
            erc20SupplyParameters_.ds.maxTokensPerWallet * (10 ** decimals())
        );
        ds.maxTokensPerTransaction = uint112(
            erc20SupplyParameters_.maxTokensPerTxn * (10 ** decimals())
        );
        ds.lpLockupInDays = uint88(erc20SupplyParameters_.ds.lpLockupInDays);
        ds.burnLPTokens = erc20SupplyParameters_.ds.burnLPTokens;

        ds._unlimited.add(address(this));
        ds._unlimited.add(address(0));
    }
}
