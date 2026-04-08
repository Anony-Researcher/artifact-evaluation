// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract SetOwnerFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    function SetOwner(address payable newOwner) external onlyowner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.owner = newOwner;
    }
}
