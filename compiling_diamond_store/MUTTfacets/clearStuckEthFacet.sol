/**
Web: https://MUTTeth.com

TG : https://T.me/MUTTeth

X : https://twitter.com/MUTTeth
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;
import "./TestLib.sol";
contract clearStuckEthFacet is ERC20 {
    function clearStuckEth() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds.marketingWallet);
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }
}
