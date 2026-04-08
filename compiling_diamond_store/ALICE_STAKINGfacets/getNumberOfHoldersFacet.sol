pragma solidity 0.8.9;
import "./TestLib.sol";
contract getNumberOfHoldersFacet {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    function getNumberOfHolders() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.holders.length();
    }
}
