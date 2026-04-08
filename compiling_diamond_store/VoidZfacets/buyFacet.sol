// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract buyFacet is ERC721 {
    function buy(uint orderId) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Trade storage trade = ds.trades[orderId];
        require(trade.isSold == false, "TestLib.Trade already sold");
        require(trade.publisher != address(0), "TestLib.Trade does not exists");

        // uint feeAmount = trade.amount * ds.FEE / 100;
        ds.USDT.transferFrom(
            msg.sender,
            trade.publisher,
            trade.amount - ds.FEE
        );
        _safeMint(msg.sender, orderId);

        trade.isSold = true;
    }
}
