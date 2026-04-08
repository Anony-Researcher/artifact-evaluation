// SPDX-License-Identifier: MIT

/*

Fee receiver for all utilities deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/

*/

pragma solidity 0.8.25;
import "./TestLib.sol";
contract depositETHFacet {
    modifier onlyTeam() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.team[msg.sender] || msg.sender == ds.utilRecovery);
        _;
    }

    function depositETH() external payable {
        require(msg.value > 0);
    }
}
