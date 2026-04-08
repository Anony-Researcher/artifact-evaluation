/*
https://t.me/Quantum_Network_Portal
https://quantum-network.app/

>>>Quantum Network sets the stage for processing a high throughput of transactions without compromising on the core tenets of decentralization.<<<

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;
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
