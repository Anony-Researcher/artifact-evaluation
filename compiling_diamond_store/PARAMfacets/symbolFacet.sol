/*
 * SPDX-License-Identifier: MIT
 * Website: https://airdrops.io/visit/97n2/
 * Twitter: https://twitter.com/paramlaboratory
 * Discord Chat: https://airdrops.io/visit/a7n2/
 */
pragma solidity ^0.8.21;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
