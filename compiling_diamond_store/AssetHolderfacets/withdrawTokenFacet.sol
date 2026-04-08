// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract withdrawTokenFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event WithdrawnToken(address token, address to, uint256 amount);
    function withdrawToken(address tokenAddress) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No token balance");
        emit WithdrawnToken(tokenAddress, ds.owner, balance);
        token.transfer(ds.owner, balance);
    }
}
