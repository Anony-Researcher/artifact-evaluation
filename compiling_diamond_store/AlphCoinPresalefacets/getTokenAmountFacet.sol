pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getTokenAmountFacet is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    modifier saleStarted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isPresaleStarted, "PreSale: Sale has already started");
        _;
    }

    function getTokenAmount(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.isPresaleStarted) {
            return 0;
        }
        uint256 amtOut;
        if (token != address(0)) {
            require(
                ds.tokenWL[token] == true,
                "Presale: Token not whitelisted"
            );
            uint256 price = ds.tokenPrices[token];
            amtOut = amount.mul(10 ** ds.saleTokenDec).div(price);
        } else {
            amtOut = amount.mul(10 ** ds.saleTokenDec).div(ds.rate);
        }
        return amtOut;
    }
    function buyToken(address _token, uint256 _amount) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isPresaleStarted, "PreSale: Sale stopped!");

        uint256 saleTokenAmt;
        if (_token != address(0)) {
            require(_amount > 0, "Presale: Cannot buy with zero amount");
            require(
                ds.tokenWL[_token] == true,
                "Presale: Token not whitelisted"
            );

            saleTokenAmt = getTokenAmount(_token, _amount);

            // check if saleTokenAmt is greater than ds.minBuyLimit
            require(
                saleTokenAmt >= ds.minBuyLimit,
                "Presale: Min buy limit not reached"
            );
            require(
                ds.presaleData[msg.sender] + saleTokenAmt <= ds.maxBuyLimit,
                "Presale: Max buy limit reached for this phase"
            );
            require(
                (ds.totalTokensSold + saleTokenAmt) <= ds.totalTokensforSale,
                "PreSale: Total Token Sale Reached!"
            );

            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        } else {
            saleTokenAmt = getTokenAmount(address(0), msg.value);

            // check if saleTokenAmt is greater than ds.minBuyLimit
            require(
                saleTokenAmt >= ds.minBuyLimit,
                "Presale: Min buy limit not reached"
            );
            require(
                ds.presaleData[msg.sender] + saleTokenAmt <= ds.maxBuyLimit,
                "Presale: Max buy limit reached for this phase"
            );
            require(
                (ds.totalTokensSold + saleTokenAmt) <= ds.totalTokensforSale,
                "PreSale: Total Token Sale Reached!"
            );
        }

        ds.totalTokensSold += saleTokenAmt;
        ds.buyersAmount[msg.sender].amount += saleTokenAmt;
        ds.presaleData[msg.sender] += saleTokenAmt;
    }
}
