pragma solidity 0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
