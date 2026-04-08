// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract signPetitionFacet {
    function signPetition() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.signatures[msg.sender], "Already signed the petition");
        require(
            ds.ch4n63Token.transfer(msg.sender, 10 * 10 ** 18),
            "Token transfer failed"
        );
        ds.signatures[msg.sender] = true;
        ds.totalSignatures++;
    }
}
