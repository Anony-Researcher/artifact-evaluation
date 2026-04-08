// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract SetStakeDurationFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third
    ) external onlyowner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.Duration[0] = first;
        ds.Duration[1] = second;
        ds.Duration[2] = third;
    }
}
