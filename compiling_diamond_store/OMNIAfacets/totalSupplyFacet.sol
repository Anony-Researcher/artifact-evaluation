// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://omniatech.io/
    Twitter:  https://twitter.com/omnia_protocol
    Medium:   https://medium.com/omniaprotocol
    Telegram: https://t.me/Omnia_protocol

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
}
