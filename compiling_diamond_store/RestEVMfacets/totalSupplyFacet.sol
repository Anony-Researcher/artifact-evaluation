pragma solidity 0.8.24;
import "./TestLib.sol";
contract totalSupplyFacet {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }
}
