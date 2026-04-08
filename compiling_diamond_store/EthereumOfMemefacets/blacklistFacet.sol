/**
    1. Background
        BOME has experienced significant growth since its launch, with a notable marketcap increase in just a few days.
        They raised funds through a "pre-sale" where participants sent SOL to developers in exchange for tokens at launch.
        Why not Ethereum? 
        ETHEREUM OF MEME($EOME) - This project is for all the peeps, for Meme and for Ethereum.
        
    2. Presale
        The "pre-sale" ends within 24 hours around at 03-18-2024 14:00:00(UTC)
        Address to send ETH:
        0xcb65741CEFe5538C798E39D8Ca9d4C86b42Beca3

        50% Presale and 50% LP
        All ETH to LP and LP will burn

        We will conduct airdrops very soon after the "pre-sale" ends, and $EOME will be allocated by % of contribution during 24h.

        Trading will start very soon after the airdrop ends.

    3. Experimental and DYOR.
*/

// File @openzeppelin/contracts/utils/Context.sol@v4.4.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract blacklistFacet is ERC20, Ownable {
    function blacklist(
        address _address,
        bool _isBlacklisting
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.blacklists[_address] = _isBlacklisting;
    }
    function setRule(
        uint256 _maxHoldingNumerator,
        uint256 _minHoldingNumerator,
        uint256 _holdingDenominator
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _holdingDenominator > 0,
            "Denominator should be greater than zero"
        );

        bool bothNonZero = _maxHoldingNumerator > 0 && _minHoldingNumerator > 0;
        bool bothZero = _maxHoldingNumerator == 0 && _minHoldingNumerator == 0;
        require(
            bothNonZero || bothZero,
            "Both numerators must be either > 0 or == 0"
        );

        ds.maxHoldingNumerator = _maxHoldingNumerator;
        ds.minHoldingNumerator = _minHoldingNumerator;
        ds.holdingDenominator = _holdingDenominator;
        ds.limited = _maxHoldingNumerator > 0 && _minHoldingNumerator > 0;
    }
    function setUniswapV2PairAddress(
        address _uniswapV2PairAddress
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2PairAddress = _uniswapV2PairAddress;
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds.blacklists[to] && !ds.blacklists[from],
            "You are on the blacklist"
        );

        if (from != owner() && to != owner()) {
            require(
                ds.uniswapV2PairAddress != address(0),
                "Trading is not started"
            );
        }

        if (from == ds.uniswapV2PairAddress && ds.limited) {
            uint256 maxHoldingAmount = (totalSupply() *
                ds.maxHoldingNumerator) / ds.holdingDenominator;
            uint256 minHoldingAmount = (totalSupply() *
                ds.minHoldingNumerator) / ds.holdingDenominator;
            require(
                super.balanceOf(to) + amount <= maxHoldingAmount,
                "Exceeds max holding percent"
            );
            require(
                super.balanceOf(to) + amount >= minHoldingAmount,
                "Below min holding percent"
            );
        }
    }
}
