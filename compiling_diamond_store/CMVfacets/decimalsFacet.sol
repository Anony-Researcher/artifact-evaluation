/*
CMV - Reshaping Crypto Valuation
Embark on a groundbreaking journey with CMV, a token that transcends traditional metrics to mirror the crypto market’s real-time value. 
As the digital currency landscape enters a bullish phase in 2024, with market capitalization soaring past the $2 trillion mark, 
CMV emerges as a vital tool for investors and enthusiasts alike, providing a comprehensive index that captures the essence of the market’s dynamics.
Website: https://cryptomarketvalue.xyz
Telegram: https://t.me/Cryptomarketvalue
Twitter: https://twitter.com/CMV_2024
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
