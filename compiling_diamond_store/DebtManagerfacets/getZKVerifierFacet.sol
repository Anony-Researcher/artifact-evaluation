// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.21;
import "./TestLib.sol";
contract getZKVerifierFacet {
    function getZKVerifier() external view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._zkVerifier;
    }
}
