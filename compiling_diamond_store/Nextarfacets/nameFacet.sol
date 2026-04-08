/**
 */

// Nextar EVM Layer 1 Blockchain project represents a cutting-edge advancement in blockchain technology

// Telegram : https://t.me/NextarOfficial
// Twitter  : https://x.com/Nextar_io
// Website  : https://nextar.io/
// Docs     : https://nextar.gitbook.io/nextar-whitepaper-v.1/
// Medium   : https://medium.com/@nextar_official

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
