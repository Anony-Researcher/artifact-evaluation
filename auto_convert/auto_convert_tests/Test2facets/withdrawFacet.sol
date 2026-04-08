// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/utils/Address.sol";

import "./TestLib.sol";
contract withdrawFacet {
    function withdraw() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Checkpoint memory name;
        name.amount = 100;
        uint bal = ds.balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        ds.balances[msg.sender] = 0;
    }
}
