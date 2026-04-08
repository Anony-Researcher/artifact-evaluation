// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://omniatech.io/
    Twitter:  https://twitter.com/omnia_protocol
    Medium:   https://medium.com/omniaprotocol
    Telegram: https://t.me/Omnia_protocol

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokensymbol;
    }
}
