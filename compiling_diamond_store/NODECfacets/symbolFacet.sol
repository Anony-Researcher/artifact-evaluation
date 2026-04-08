/*

Node Chain is a next-generation, Ethereum-compatible blockchain designed to offer low, 
constant gas fees and high throughput, 
ensuring efficiency and scalability for a wide range of applications.

TELEGRAM : https://t.me/NodeChainNet
TWITTER : https://twitter.com/NodeChainNet
WEBSITE : https://nodec.org

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
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
