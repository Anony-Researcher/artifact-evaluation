// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract SetStakeBonusFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third
    ) external onlyowner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.Bonus[0] = first;
        ds.Bonus[1] = second;
        ds.Bonus[2] = third;
    }
}
