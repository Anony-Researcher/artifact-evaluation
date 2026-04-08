pragma solidity ^0.5.0;
import "./TestLib.sol";
contract symbolFacet is ERC20 {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
}
