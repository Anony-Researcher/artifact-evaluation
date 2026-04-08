// SPDX-License-Identifier: MIT

/*

This is a secure storage contract deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/storage

*/

pragma solidity 0.8.25;
import "./TestLib.sol";
contract withdrawTokenFacet {
    function withdrawToken(address token, address to, uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        IToken(token).transfer(to, amount);
    }
}
