// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://anvm.io/
    Twitter:  https://twitter.com/AINNLayer2
    Telegram:  https://t.me/AINN_ANVM

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
