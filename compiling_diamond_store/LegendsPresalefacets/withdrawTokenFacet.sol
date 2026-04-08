pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawTokenFacet is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    modifier saleStarted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    function withdrawToken() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensforWithdraw;
        require(
            ds.buyersAmount[msg.sender].isClaimed == false,
            "Presale: Already claimed"
        );
        require(ds.isUnlockingStarted, "Presale: Locking period not over yet");
        tokensforWithdraw = ds.buyersAmount[msg.sender].amount;
        ds.buyersAmount[msg.sender].isClaimed = true;
        IERC20(ds.saleToken).safeTransfer(msg.sender, tokensforWithdraw);
    }
}
