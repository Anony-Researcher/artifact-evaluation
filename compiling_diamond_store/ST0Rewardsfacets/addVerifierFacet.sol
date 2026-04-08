/*
  ______ ______ ______ ______ _____ _______ _______      ________            _____ 
 |  ____|  ____|  ____|  ____/ ____|__   __|_   _\ \    / /  ____|     /\   |_   _|
 | |__  | |__  | |__  | |__ | |       | |    | |  \ \  / /| |__       /  \    | |  
 |  __| |  __| |  __| |  __|| |       | |    | |   \ \/ / |  __|     / /\ \   | |  
 | |____| |    | |    | |___| |____   | |   _| |_   \  /  | |____   / ____ \ _| |_ 
 |______|_|    |_|    |______\_____|  |_|  |_____|   \/   |______| /_/    \_\_____|
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract addVerifierFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "Only the ds.owner can perform this action"
        );
        _;
    }
    modifier onlyVerifier() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.verifiers[msg.sender],
            "Only a designated verifier can perform this action"
        );
        _;
    }

    function addVerifier(address _verifier) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_verifier != address(0), "Invalid verifier address");
        ds.verifiers[_verifier] = true;
    }
}
