// SPDX-License-Identifier: Unlicensed

// Layer Z is an Ethereum StateNet—a new kind of L2 enabling a network
// of custom VMs powered by a shared communication and liquidity layer.

// https://layerz.network
// https://twitter.com/LayerZ_Official
// https://t.me/LayerZOfficial

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;
    using SafeCast for int256;

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
