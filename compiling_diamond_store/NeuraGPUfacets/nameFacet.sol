/*
Decentralized access to the world's most powerful GPUs

NeuraGPU is a groundbreaking decentralized platform designed to facilitate access to GPU and AI resources, 
enabling users to participate, contribute, 
and benefit from the evolving landscape of artificial intelligence. 

TELEGRAM :  https://t.me/NeuraGPUPortal
TWITTER : https://twitter.com/NeuraGPU
WEBSITE : https://neuragpu.org/

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
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
