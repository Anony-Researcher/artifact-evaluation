pragma solidity 0.8.21;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLP = true;
        _;
        ds.inSwapLP = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
