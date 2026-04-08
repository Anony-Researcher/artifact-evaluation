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
contract getApprovedClaimableAmountFacet {
    function getApprovedClaimableAmount(
        address account
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.whitelist[account];
    }
}
