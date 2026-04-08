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
contract distributeRewardFacet {
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

    event RewardDistributed(address indexed receiver, uint256 amount);
    function distributeReward(
        address _recipient,
        uint256 _amount
    ) public onlyVerifier {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_recipient != address(0), "Invalid recipient address");
        require(_amount > 0, "Invalid reward amount");

        emit RewardDistributed(_recipient, _amount);

        require(
            ds.stage0Token.transfer(_recipient, _amount),
            "Token transfer failed"
        );
    }
}
