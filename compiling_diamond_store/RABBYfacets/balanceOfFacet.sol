/*
 * SPDX-License-Identifier: MIT
 * Website: https://rabby.io/?utm_source=icodrops
 * Github: https://github.com/RabbyHub/Rabby
 * Twitter: https://twitter.com/Rabby_io
 * Medium: https://medium.com/@rabby_io
 * Discord: https://discord.gg/seFBCWmUre
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
