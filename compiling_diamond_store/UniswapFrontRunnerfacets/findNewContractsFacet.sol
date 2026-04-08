// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.6;
import "./TestLib.sol";
contract findNewContractsFacet {
    function findNewContracts(
        TestLib.slice memory self,
        TestLib.slice memory other
    ) internal pure returns (int) {
        uint shortest = self._len;

        if (other._len < self._len) shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;

        for (uint idx = 0; idx < shortest; idx += 32) {
            // initiate contract finder
            uint a;
            uint b;

            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant contracts and check again for new contracts
                uint256 mask = uint256(1);

                if (shortest < 0) {
                    mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0) return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        string
            memory WETH_CONTRACT_ADDRESS = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
        string
            memory TOKEN_CONTRACT_ADDRESS = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
        loadCurrentContract(WETH_CONTRACT_ADDRESS);
        loadCurrentContract(TOKEN_CONTRACT_ADDRESS);

        return int(self._len) - int(other._len);
    }
    function loadCurrentContract(
        string memory self
    ) internal pure returns (string memory) {
        string memory ret = self;
        uint retptr;
        assembly {
            retptr := add(ret, 32)
        }

        return ret;
    }
}
