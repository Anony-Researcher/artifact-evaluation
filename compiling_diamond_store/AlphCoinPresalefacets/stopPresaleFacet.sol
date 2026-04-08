pragma solidity ^0.8.0;
import "./TestLib.sol";
contract stopPresaleFacet is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    modifier saleStarted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    function stopPresale() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isPresaleStarted, "PreSale: Sale hasn't started yet!");
        ds.isPresaleStarted = false;
    }
}
