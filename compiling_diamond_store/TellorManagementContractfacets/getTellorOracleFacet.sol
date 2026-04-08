// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract getTellorOracleFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function getTellorOracle() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return address(ds.tellorFlex);
    }
}
