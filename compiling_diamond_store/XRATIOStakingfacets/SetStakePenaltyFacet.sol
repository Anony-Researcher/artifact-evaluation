// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract SetStakePenaltyFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    function SetStakePenalty(
        uint256 first,
        uint256 second,
        uint256 third
    ) external onlyowner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.Penalty[0] = first;
        ds.Penalty[1] = second;
        ds.Penalty[2] = third;
    }
}
