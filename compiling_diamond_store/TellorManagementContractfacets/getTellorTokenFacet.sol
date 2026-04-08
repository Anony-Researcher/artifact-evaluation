// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract getTellorTokenFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function getTellorToken() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return address(ds.tellorToken);
    }
}
