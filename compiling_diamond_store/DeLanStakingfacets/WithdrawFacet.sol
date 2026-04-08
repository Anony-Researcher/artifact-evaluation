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
contract WithdrawFacet is Ownable {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    event WithdrawEvent(uint256 value, address to);
    function Withdraw(uint256 amount) external withdrawOrOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(address(this).balance >= amount, "Insufficient balance");
        bool sent = false;
        if (owner() != address(0)) {
            (sent, ) = owner().call{value: amount}("");
        } else if (ds.WithdrawAccount != address(0)) {
            (sent, ) = ds.WithdrawAccount.call{value: amount}("");
        } else {
            revert WithdrawAccountIsNotSet();
        }
        require(sent, "Failed to withdraw Ether");

        emit WithdrawEvent(amount, msg.sender);

        return true;
    }
}
