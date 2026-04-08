// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract changeAPYFacet {
    using SafeMath for uint256;

    function changeAPY(uint256 _value) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //only ds.owner can issue airdrop
        require(msg.sender == ds.owner, "Only contract creator can change APY");
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        ds.defaultAPY = _value;
    }
}
