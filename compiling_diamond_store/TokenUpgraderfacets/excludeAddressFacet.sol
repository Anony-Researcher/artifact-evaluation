// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./TestLib.sol";
contract excludeAddressFacet {
    using SafeERC20 for IEEFIToken;

    event TokenUpgrade(address indexed user, uint256 amount);
    function excludeAddress(address _address, bool exclude) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedAddresses[_address] = exclude;
    }
    function upgrade() external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //Require sender is not on excluded addresses list
        require(
            ds.excludedAddresses[msg.sender] == false,
            "TokenUpgrader: Address is not authorized to upgrade"
        );

        // Retrieve vesting schedules and token claim data
        ScheduleInfo[] memory infos = vesting.retrieveScheduleInfo(msg.sender);

        // Calculate the total amount of tokens that can be upgraded based on the vesting schedules
        // and the amount of tokens claimed by the user from them.
        // Round 3 schedules are ignored
        uint256 validClaimableAmount = 0;
        for (uint i = 0; i < infos.length; i++) {
            ScheduleInfo memory info = infos[i];
            require(info.asset == address(oldEEFI)); // Make sure asset being swapped is old EEFI
            // Filter out Round 3 vesting activity
            if (infos[i].startTime <= VESTING_DEADLINE) {
                // Count as upgradable only tokens claimed from Vesting contract
                validClaimableAmount += info.claimedAmount;
            }
        }

        require(
            validClaimableAmount > 0,
            "TokenUpgrader: No tokens to upgrade, have you claimed the old tokens from vesting?"
        );

        // Subtract tokens that user already upgraded to prevent user from claiming more tokens than owed
        uint256 toUpgrade = validClaimableAmount -
            ds.upgradedUserTokens[msg.sender];

        // Update the upgraded tokens count for this user
        ds.upgradedUserTokens[msg.sender] += toUpgrade;

        require(
            toUpgrade > 0,
            "TokenUpgrader: All claimed tokens have already been upgraded"
        );

        // Make sure user has oldEEFI in wallet
        uint256 balance = oldEEFI.balanceOf(msg.sender);
        require(
            toUpgrade <= balance,
            "TokenUpgrader: You must have the tokens to upgrade in your wallet"
        );

        // Remove old EEFI tokens from the user
        oldEEFI.safeTransferFrom(msg.sender, address(this), toUpgrade);

        // TokenUpgrader must have minting rights on the new EEFI token
        // toUpgrade can't be higher than the balance of old eefi from the user wallet
        // this means that the contract can't get tricked into minting more tokens than it should
        newEEFI.mint(msg.sender, toUpgrade);

        emit TokenUpgrade(msg.sender, toUpgrade);
    }
}
