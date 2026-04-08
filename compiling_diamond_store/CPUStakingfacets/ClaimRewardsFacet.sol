/*
Crypto Processing Unit - $CPU

Website:       https://cryptopu.io
Doc:           https://docs.cryptopu.io/
dAPP:          https://dapp.cryptopu.io/
Telegram:      https://t.me/CPU_official
Telegram Bot:  https://t.me/CryptoProcessingUnitBot
Twitter:       https://twitter.com/CPU_erc
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
