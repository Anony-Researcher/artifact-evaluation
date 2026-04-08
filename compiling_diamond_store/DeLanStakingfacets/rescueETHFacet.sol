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
contract rescueETHFacet {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    function rescueETH(address to, uint16 percent) external withdrawOrOwner {
        percent = percent > 100 ? 100 : percent;
        uint256 amount = (address(this).balance * percent) / 100;
        require(amount > 0, "Insufficient balance or invalid percentage");
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "Failed to withdraw Ether");
    }
}
