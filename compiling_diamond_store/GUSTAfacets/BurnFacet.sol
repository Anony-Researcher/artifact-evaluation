// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;
import "./TestLib.sol";
contract BurnFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function Burn(uint256 burnTokenAmount) public {
        require(
            burnTokenAmount >= balanceOf(msg.sender),
            "can't burn more than you holding"
        );
        _burn(msg.sender, burnTokenAmount);
    }
}
