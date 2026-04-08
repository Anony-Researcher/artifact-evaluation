/*

    Tg: https://t.me/CxsTechnologies

    X: https://twitter.com/cxstechnologies

    Web: https://c-x-s.org
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract burnFacet is ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) external {
        require(amount > 0, "cannot burn zero");
        _burn(msg.sender, amount);
    }
}
