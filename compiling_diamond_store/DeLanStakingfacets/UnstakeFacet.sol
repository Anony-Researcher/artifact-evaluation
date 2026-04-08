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
contract UnstakeFacet {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    function Unstake(uint256 amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.Stakes[msg.sender] >= amount, "Insufficient staked amount");
        IERC20(ds.RewardTokenAddress).transfer(msg.sender, amount);

        // record unstake
        ds.totalStakedAmount -= amount;
        ds.Stakes[msg.sender] -= amount;
    }
}
