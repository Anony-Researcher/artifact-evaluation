/**
https://t.me/Profit_IQ
https://profitiqai.tech
https://twitter.com/profit_IQERC
**/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.12;
import "./TestLib.sol";
contract nameFacet is Ownable {
    function name() public pure returns (string memory) {
        return _name;
    }
}
