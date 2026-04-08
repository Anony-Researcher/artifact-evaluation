// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract publishFacet {
    event published(address sender, uint artwork, uint amount);
    function publish(uint _amount, uint _id) external returns (uint id) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _amount > ds.FEE,
            "Price should be greater than ds.FEE amount."
        );
        id = ++ds.lastOrderId;
        TestLib.Trade storage trade = ds.trades[_id];

        trade.amount = _amount;
        trade.artwork = _id;
        trade.publisher = msg.sender;

        emit published(msg.sender, _id, _amount);
    }
}
