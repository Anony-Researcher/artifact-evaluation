// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract setLpPairFacet {
    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._owner == msg.sender, "Caller =/= owner.");
        _;
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!enabled) {
            ds.lpPairs[pair] = false;
            ds.initializer.setLpPair(pair, false);
        } else {
            if (ds.timeSinceLastPair != 0) {
                require(
                    block.timestamp - ds.timeSinceLastPair > 3 days,
                    "3 Day cooldown."
                );
            }
            require(!ds.lpPairs[pair], "Pair already added to list.");
            ds.lpPairs[pair] = true;
            ds.timeSinceLastPair = block.timestamp;
            ds.initializer.setLpPair(pair, true);
        }
    }
}
