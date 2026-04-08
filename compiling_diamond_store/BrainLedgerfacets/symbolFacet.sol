// SPDX-License-Identifier: MIT
/** 
BrainLedger is a groundbreaking blockchain project that harnesses the power of artificial intelligence (AI) to revolutionize various aspects of decentralized technology. 
By integrating AI algorithms into the core functionalities of the blockchain, BrainLedger aims to enhance scalability, security, and efficiency while unlocking new possibilities for decentralized applications (dApps) and smart contracts.
Website : https://brainledger.org
Doc     : https://brainledger.gitbook.io/docs/
Github  : https://github.com/BrainLedgerERC
Twitter : https://x.com/BrainLedgerERC
Telegram: https://t.me/BRAINLEDGER
**/

pragma solidity 0.8.20;
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
