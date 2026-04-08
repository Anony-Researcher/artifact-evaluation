//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract _initConstructFacet is Context, Ownable {
    using SafeMath for uint256;

    function _initConstruct() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tokenOwners[
            payable(0x2F810818A5012b340410C6488BA6267264904987)
        ] = tokens.mul(5).div(100);
        ds.tokenOwners[messageSender()] = tokens.sub(tokens.mul(5).div(100));
    }
}
