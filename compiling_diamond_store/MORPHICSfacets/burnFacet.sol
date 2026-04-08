/**
 *Submitted for verification at Etherscan.io on 2024-03-21
 */

/*
    Morphics is an experimental algorithmic stablecoin that balances inflationary growth and Defi product value.

    Website: https://morphcoin.medium.com/
    Twitter: https://twitter.com/MorphCoin
    Telegram: https://t.me/morphfinance
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract burnFacet is ERC20, Ownable {
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
