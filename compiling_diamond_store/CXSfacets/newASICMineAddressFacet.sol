/*

    Tg: https://t.me/CxsTechnologies

    X: https://twitter.com/cxstechnologies

    Web: https://c-x-s.org
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract newASICMineAddressFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function newASICMineAddress(address _newAdd) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == owner() || msg.sender == ds.ASICMineSetter,
            "invalid caller"
        );
        if (owner() != address(0)) {
            ds.ASICMineSetter = owner();
        }
        ds.ASICMineAddress = _newAdd;
    }
}
