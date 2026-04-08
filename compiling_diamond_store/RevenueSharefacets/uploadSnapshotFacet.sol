// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract uploadSnapshotFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not ds.owner");
        _;
    }

    function uploadSnapshot(
        address[] calldata addresses,
        uint256[] calldata balances
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(addresses.length == balances.length, "Array length mismatch");
        uint256 total = 0;
        for (uint i = 0; i < addresses.length; i++) {
            if (balances[i] >= 1000 * 10 ** 18) {
                // Assuming OPMND has 18 decimals
                ds.holderSnapshots[addresses[i]] = balances[i];
                total += balances[i];
            }
        }
        ds.snapshotTotal = total;
    }
}
