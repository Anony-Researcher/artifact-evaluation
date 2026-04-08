// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract checkTokenBalanceFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    function checkTokenBalance(
        address tokenAddress
    ) public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }
}
