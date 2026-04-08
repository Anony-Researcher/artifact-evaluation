pragma solidity 0.8.21;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLP = true;
        _;
        ds.inSwapLP = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
