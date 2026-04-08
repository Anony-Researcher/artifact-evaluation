// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract SetDividerFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    function SetDivider(uint256 percent) external onlyowner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.percentDivider = percent;
    }
}
