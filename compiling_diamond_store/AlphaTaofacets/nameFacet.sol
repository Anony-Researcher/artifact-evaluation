/**
 *Submitted for verification at Etherscan.io on 2022-10-17
 */

// SPDX-License-Identifier: MIT
/**

$NTI | Nato Inu

"The NATO treaty is crystal clear on this one: An attack on one nation shall be regarded as an attack on all of them."

Read this Article to find out more about $NTI and the Team behind it:
https://medium.com/@NatoInu/nti-nato-inu-959e4b768680

Socials
- twitter.com/NatoInuETH
- https://t.me/NatoInuPortal
- https://medium.com/@NatoInu

**/
pragma solidity 0.8.17;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
