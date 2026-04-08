// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract changepoolStatusFacet {
    using SafeMath for uint256;

    function changepoolStatus(bool _value) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //only ds.owner can issue airdrop
        require(
            msg.sender == ds.owner,
            "Only contract creator can change Pool Status"
        );
        ds.poolStatus = _value;
    }
}
