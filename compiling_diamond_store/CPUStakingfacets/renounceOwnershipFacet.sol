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
