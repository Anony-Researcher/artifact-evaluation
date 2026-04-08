pragma solidity ^0.5.0;
import "./TestLib.sol";
contract decimalsFacet is ERC20 {
    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
}
