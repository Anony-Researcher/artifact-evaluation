// SPDX-License-Identifier: MIT
/*
Website : https://bvengine.network/
GitBook : https://bitcoin-virtual-engine.gitbook.io/bitcoin-virtual-engine-bve/

Twitter : https://twitter.com/BitcoinBVE
Telegram : https://t.me/BitcoinVirtualEngine

*/

pragma solidity ^0.8.9;
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
