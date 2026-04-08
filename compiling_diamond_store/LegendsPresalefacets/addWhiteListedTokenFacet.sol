pragma solidity ^0.8.0;
import "./TestLib.sol";
contract addWhiteListedTokenFacet is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    modifier saleStarted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    function addWhiteListedToken(
        address _token,
        uint256 _price
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_price != 0, "Presale: Cannot set price to 0");
        ds.tokenWL[_token] = true;
        ds.tokenPrices[_token] = _price;
    }
}
