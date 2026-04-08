// telegram: https://t.me/flepeth
// website: https://flepe.io
// X Handle: https://x.com/flepeth

// Floki vs Pepe
// $FLEPE > $FLOKI $PEPE

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
