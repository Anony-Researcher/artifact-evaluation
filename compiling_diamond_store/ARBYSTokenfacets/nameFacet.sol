pragma solidity ^0.5.0;
import "./TestLib.sol";
contract nameFacet is ERC20 {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
}
