/*
DeLan Network - The fully telegram integrated decentralised IP exchange to limitless internet.

Website:       https://delannetwork.tech
DAPP:          https://t.me/DeLanNetworkBot
TELEGRAM:      https://t.me/DeLanNetwork_portal
TWITTER:       https://twitter.com/DeLanNetwork
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract ClaimRewardsFacet {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    event ClaimEvent(uint256 value, address from);
    function ClaimRewards() external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.totalStakedAmount > 0, "No stakes");
        uint256 amount = ds.waitForClaim[msg.sender];
        require(
            balanceOfRewardToken() >= amount,
            "Insufficient reward balance"
        );
        if (amount == 0) {
            return false;
        }

        ds.waitForClaim[msg.sender] -= amount;

        _claimRewards(amount);

        return true;
    }
    function balanceOfRewardToken() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return IERC20(ds.RewardTokenAddress).balanceOf(address(this));
    }
    function _claimRewards(uint256 amount) private {
        _transferRewardToken(msg.sender, amount);

        emit ClaimEvent(amount, msg.sender);

        return;
    }
    function _transferRewardToken(
        address to,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return IERC20(ds.RewardTokenAddress).transfer(to, amount);
    }
}
