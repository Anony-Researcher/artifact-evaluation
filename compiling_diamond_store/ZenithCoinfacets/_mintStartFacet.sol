// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _mintStartFacet {
    function _mintStart(
        address receiver,
        uint256 rSupply,
        uint256 tSupply
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(receiver != address(0), "ERC20: mint to the zero address");

        ds._rOwned[receiver] = ds._rOwned[receiver] + rSupply;
        emit Transfer(address(0), receiver, tSupply);
    }
}
