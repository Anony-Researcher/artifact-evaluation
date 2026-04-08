/**

CrowdDrive Airdrop Claimer

Website: https://cdrive.cx

Twitter: https://twitter.com/cdrive_eth

Telegram: https://t.me/cdriveportal

*/

//SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract claimTokensFacet {
    event TokensClaimed(address indexed account, uint256 amount);
    function claimTokens() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.whitelist[msg.sender] > 0,
            "Address is not whitelisted or has already claimed"
        );

        uint256 claimableAmount = ds.whitelist[msg.sender];
        ds.whitelist[msg.sender] = 0;

        require(
            ds.token.transfer(msg.sender, claimableAmount),
            "Token transfer failed"
        );
        emit TokensClaimed(msg.sender, claimableAmount);
    }
}
