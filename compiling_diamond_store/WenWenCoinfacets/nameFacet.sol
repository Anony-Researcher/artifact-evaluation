/*
 * SPDX-License-Identifier: MIT
 * Twitter: https://twitter.com/wenwencoin
 * Website: https://www.wenwencoin.com/
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
