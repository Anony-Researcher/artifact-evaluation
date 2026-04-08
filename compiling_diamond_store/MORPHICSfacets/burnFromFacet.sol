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
contract burnFromFacet is ERC20, Ownable {
    function burnFrom(address account, uint256 amount) external {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}
