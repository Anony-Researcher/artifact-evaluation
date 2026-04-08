// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract setSwapTokensAtAmountFacet {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    event SwapTokensAtAmountChanged(uint256 amount);
    event ExcludeFromFees(address indexed account);
    event IncludeInFees(address indexed account);
    event ExcludeMultipleAccountsFromFees(address[] accounts);
    event UpdatedTreasuryWallet(address account);
    event UpdatedLiquidityShare(uint256 liquidityPercent);
    event UpdatedTreasuryETHShare(uint256 treasuryETHPercent);
    event UpdatedFee(uint256 amount);
    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount > totalSupply() / 10 ** 5 &&
                amount <= totalSupply() / 10 ** 3,
            "Amount must be between 0.001% - 0.1 of total supply"
        );
        ds.swapTokensAtAmount = amount;

        emit SwapTokensAtAmountChanged(amount);
    }
    function excludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds._isExcludedFromFees[account],
            "Account is already excluded"
        );

        ds._isExcludedFromFees[account] = true;

        emit ExcludeFromFees(account);
    }
    function includeInFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._isExcludedFromFees[account], "Account is already included");

        ds._isExcludedFromFees[account] = false;

        emit IncludeInFees(account);
    }
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds._isExcludedFromFees[accounts[i]] = true;
        }

        emit ExcludeMultipleAccountsFromFees(accounts);
    }
    function setTreasuryWallet(address payable wallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(wallet != address(0), "Can not be address(0).");

        ds.treasuryWallet = wallet;

        emit UpdatedTreasuryWallet(wallet);
    }
    function setLiquidityShare(uint256 liquidityPercent) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            liquidityPercent <= 100,
            "Liquidity share can not be over 100%."
        );

        ds.liquidityShare = liquidityPercent;

        emit UpdatedLiquidityShare(ds.liquidityShare);
    }
    function setTreasuryETHShare(
        uint256 treasuryETHPercent
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            treasuryETHPercent <= 100,
            "Liquidity share can not be over 100%."
        );

        ds.treasuryETHShare = treasuryETHPercent;

        emit UpdatedTreasuryETHShare(ds.treasuryETHShare);
    }
    function setFee(uint256 value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(value <= 2000, "Total fees can not be over 20%.");

        ds.totalFees = value;

        emit UpdatedFee(value);
    }
}
