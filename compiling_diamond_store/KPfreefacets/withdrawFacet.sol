/**
 *Submitted for verification at testnet.bscscan.com on 2024-04-08
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./TestLib.sol";
contract withdrawFacet is ERC20Base {
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance); //transfer all the tokens to the sender
    }
}
