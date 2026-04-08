/**
ZKLT | Unleashing Decentralized Blockchain with Web3, GPU Node, Revenue Sharing and Trading Tools

https://testnet-explorer.zklt.systems
zklt.systems
https://t.me/zkltnode
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
