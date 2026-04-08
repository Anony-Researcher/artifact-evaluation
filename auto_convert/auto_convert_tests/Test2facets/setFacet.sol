// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/utils/Address.sol";

import "./TestLib.sol";
contract setFacet {
    function set(TestLib.Status _status) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.status = _status;
    }
}
