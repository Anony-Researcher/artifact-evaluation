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
contract StakeFacet {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    event StakeEvent(uint256 value, address from);
    function Stake(uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // use erc20 transfer for this contract is staking erc20 token
        safeTransferFrom(
            ds.RewardTokenAddress,
            msg.sender,
            address(this),
            amount
        );
        // total
        ds.totalStakedAmount += amount;
        ds.totalStakedRecord += amount;
        // user
        if (!ds.inStakers[msg.sender]) {
            ds.inStakers[msg.sender] = true;
            ds.Stakers.push(msg.sender);
        }
        ds.Stakes[msg.sender] += amount;

        emit StakeEvent(amount, msg.sender);

        return;
    }
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ERC20: TRANSFER_FROM_FAILED"
        );
    }
    function sendReward(uint256 amount) public withdrawOrOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // transfer to address(this)
        safeTransferFrom(
            ds.RewardTokenAddress,
            msg.sender,
            address(this),
            amount
        );
        ds.totalRewardSentRecord += amount;
        // according to current stakes, calculate rewards, and put into ds.waitForClaim
        for (uint256 i = 0; i < ds.Stakers.length; i++) {
            address staker = ds.Stakers[i];

            uint256 reward = (amount * ds.Stakes[staker]) /
                ds.totalStakedAmount;
            ds.waitForClaim[staker] += reward;
        }
        return true;
    }
}
