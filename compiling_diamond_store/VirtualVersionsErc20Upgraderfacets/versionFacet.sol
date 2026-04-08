// SPDX-License-Identifier: MIT

pragma solidity =0.8.9;
import "./TestLib.sol";
contract versionFacet {
    modifier onlyAdmin() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.admin_, "TA-4: auth failed");
        _;
    }

    function version() external pure returns (string memory) {
        return "VirtualVersionsErc20Upgrader v1";
    }
}
