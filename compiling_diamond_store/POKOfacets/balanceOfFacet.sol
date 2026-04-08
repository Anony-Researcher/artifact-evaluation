/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.pokoapp.xyz/?utm_source=icodrops
 * Twitter: https://twitter.com/poko_app
 * Linkedin: https://www.linkedin.com/company/pokoapp/
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
