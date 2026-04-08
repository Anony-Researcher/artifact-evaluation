// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract changeTotalpoolFacet {
    using SafeMath for uint256;

    function changeTotalpool(uint256 _value) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //only ds.owner can issue airdrop
        require(
            msg.sender == ds.owner,
            "Only contract creator can change Total pool"
        );
        require(
            _value > 0,
            "Pool value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        ds.totalPool = _value * (10 ** 18);
    }
}
