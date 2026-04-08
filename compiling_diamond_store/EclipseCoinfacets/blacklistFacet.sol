/**
 *Submitted for verification at Etherscan.io on 2023-04-14
 */

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts/utils/Context.sol@v4.4.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

//Website: EclipseCoin.xyz
//Twitter: www.twitter.com/EclipseCoin
pragma solidity ^0.8.0;
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
        bool _limited,
        address _uniswapV2Pair,
        uint256 _maxHoldingAmount,
        uint256 _minHoldingAmount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limited = _limited;
        ds.uniswapV2Pair = _uniswapV2Pair;
        ds.maxHoldingAmount = _maxHoldingAmount;
        ds.minHoldingAmount = _minHoldingAmount;
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.blacklists[to] && !ds.blacklists[from], "Blacklisted");

        if (ds.uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading is not started");
            return;
        }

        if (ds.limited && from == ds.uniswapV2Pair) {
            require(
                super.balanceOf(to) + amount <= ds.maxHoldingAmount &&
                    super.balanceOf(to) + amount >= ds.minHoldingAmount,
                "Forbid"
            );
        }
    }
}
