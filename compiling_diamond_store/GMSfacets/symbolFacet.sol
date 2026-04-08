/*
 * SPDX-License-Identifier: MIT
 * Twitter: https://twitter.com/Gmatrixs1
 * Website: https://gmatrixs.com
 * Medium: https://medium.com/Gmatrixs1
 * Discord: https://discord.com/invite/GDrqPFVrst
 */
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
