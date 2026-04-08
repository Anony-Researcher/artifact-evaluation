pragma solidity 0.8.24;
import "./TestLib.sol";
contract symbolFacet {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
