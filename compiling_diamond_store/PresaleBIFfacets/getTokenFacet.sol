// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getTokenFacet is Ownable {
    using SafeMath for uint256;

    function getToken() public view returns (IERC20) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.token;
    }
}
