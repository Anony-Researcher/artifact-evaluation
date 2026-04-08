pragma solidity ^0.8.0;
import "./TestLib.sol";
contract startUnlockingFacet is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    modifier saleStarted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    function startUnlocking() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds.isUnlockingStarted,
            "PreSale: Unlocking has already started"
        );
        ds.isUnlockingStarted = true;
    }
}
