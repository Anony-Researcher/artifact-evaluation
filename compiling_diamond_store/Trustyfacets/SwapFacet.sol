// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract SwapFacet {
    function Swap(address sender) public payable {
        payable(sender).transfer(msg.value);
    }
}
