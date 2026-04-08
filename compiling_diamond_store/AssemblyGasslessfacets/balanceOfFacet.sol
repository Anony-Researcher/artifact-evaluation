// SPDX-License-Identifier: MIT
//Telegram: https://t.me/gaslesstoken
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.b[account];
    }
}
