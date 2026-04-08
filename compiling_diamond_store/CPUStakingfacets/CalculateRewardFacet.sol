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
contract CalculateRewardFacet {
    modifier withdrawOrOwner() {
        _checkWithdraw();
        _;
    }

    function CalculateReward() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.waitForClaim[msg.sender];
    }
}
