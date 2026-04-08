// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract deployTSFacet {
    event TokenReceived(address sender, uint256 amount);
    event DeployedTS(
        address indexed tsAddress,
        address indexed cBuyerWallet,
        address indexed cSellerWallet
    );
    function deployTS(
        string memory NftBaseURI,
        bool EthPayment,
        uint256 ExpiryDate,
        uint256 Price,
        address PaymentToken,
        address BuyerWallet,
        address SellerWallet
    ) public payable returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20 Token = IERC20(PaymentToken);

        if (EthPayment) {
            require(msg.value >= Price, "Not enough eth");
        } else {
            require(
                Token.allowance(msg.sender, address(this)) >= Price,
                "No allowance"
            );
            require(Token.balanceOf(msg.sender) >= Price, "Not enough token");
            Token.transferFrom(msg.sender, address(this), Price);
            emit TokenReceived(msg.sender, Price);
        }
        TradeSmart ts = new TradeSmart{value: msg.value}(
            NftBaseURI,
            EthPayment,
            ExpiryDate,
            Price,
            PaymentToken,
            BuyerWallet,
            SellerWallet,
            ds.ESCROW,
            ds.REVENUE
        );
        if (EthPayment) {
            ts.mintByEth();
        } else {
            bool sent = Token.transfer(address(ts), Price);
            require(sent, "Token not sent");
            ts.mintByToken();
        }
        ds.nftInfo.push(
            TestLib.NftInfo(address(ts), BuyerWallet, SellerWallet)
        );
        emit DeployedTS(address(ts), BuyerWallet, SellerWallet);
        return address(ts);
    }
}
