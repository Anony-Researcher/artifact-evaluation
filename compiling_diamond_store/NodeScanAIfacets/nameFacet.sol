/**
Channel     : https://t.me/NodescanOfficial
Website     : https://nodescan.tech/
Twitter/x   : https://twitter.com/NodescanX
Whitepaper 	: https://doc.nodescan.tech/node-scan/

NodeScan App   : https://t.me/AuditNodeScanBot
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
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
