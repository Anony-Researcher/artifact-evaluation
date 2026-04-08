pragma solidity ^0.8.0;
import "./TestLib.sol";
contract setSaleTokenParamsFacet is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    modifier saleStarted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    function setSaleTokenParams(
        address _saleToken,
        uint256 _totalTokensforSale
    ) external onlyOwner saleStarted {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.saleToken = _saleToken;
        ds.saleTokenDec = IERC20Metadata(ds.saleToken).decimals();
        ds.totalTokensforSale = _totalTokensforSale;
        IERC20(ds.saleToken).safeTransferFrom(
            msg.sender,
            address(this),
            ds.totalTokensforSale
        );
    }
}
