pragma solidity 0.8.22;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
