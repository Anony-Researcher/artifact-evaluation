// SPDX-License-Identifier: MIT

/*

This contract is a safe utility token deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/standard

*/

pragma solidity 0.8.25;
import "./TestLib.sol";
contract renounceOwnershipFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    function renounceOwnership(bool trueToConfirm) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(trueToConfirm);
        emit OwnershipTransferred(ds.owner, address(0));
        ds.owner = address(0);
    }
}
