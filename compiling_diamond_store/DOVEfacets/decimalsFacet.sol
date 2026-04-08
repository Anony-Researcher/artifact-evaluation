pragma solidity 0.8.22;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
