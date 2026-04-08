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
contract rescueERC20Facet {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    function rescueERC20(
        address token,
        address to,
        uint16 percent
    ) external withdrawOrOwner returns (bool) {
        percent = percent > 100 ? 100 : percent;
        uint256 amount = (IERC20(token).balanceOf(address(this)) * percent) /
            100;
        require(amount > 0, "Insufficient balance or invalid percentage");
        return IERC20(token).transfer(to, amount);
    }
}
