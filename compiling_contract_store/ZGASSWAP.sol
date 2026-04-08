// SPDX-License-Identifier: MIT
// Telegram: https://t.me/zerogastoken
pragma solidity ^0.8.25;

interface IERCZGAS {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AddLiquidity(uint32 _timeTillUnlockLiquidity, uint256 value);
    event RemoveLiquidity(uint256 value);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out
    );
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract ZGASSWAP {

    address public owner;
    uint256 public fee; 
    IERCZGAS public token;
    mapping(address account => uint32) public lastTX;
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor(uint256 _fee, address _tokenAddress) {
        owner = msg.sender;
        fee = _fee;
        token = IERCZGAS(_tokenAddress);
    }


    function getReserves() public view returns (uint256, uint256) {
        return (
            (address(this).balance),
            token.balanceOf(address(this))
        );
    }

    function removeLiquidity() public onlyOwner {

        (uint256 reserveETH, ) = getReserves();

        (bool success, ) = payable(msg.sender).call{value: reserveETH}("");
        if (!success) {
            revert("Could not remove liquidity");
        }
        token.transfer(owner, token.balanceOf(address(this)));

    }
    function addLiquidity() public payable {}

    function getAmountOut(
        uint256 value,
        bool _buy // buy for true , sell for false
    ) public view returns (uint256) {
        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        if (_buy) {
            uint256 valueAfterFee = (value * (10000 - fee)) / 10000;
            return ((valueAfterFee * reserveToken)) / (reserveETH + value);
        } else {
            uint256 ethValue = ((value * reserveETH)) / (reserveToken + value);
            ethValue = (ethValue * (10000 - fee)) / 10000;
            return ethValue;
        }
    }
    function buy(uint256 amountOutMin) public payable {

        uint256 feeAmount = (msg.value * fee) / 10000;

        uint256 ETHafterFee;
        unchecked {
            ETHafterFee = msg.value - feeAmount;
        }

        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        uint256 tokenAmount = (ETHafterFee * reserveToken) / reserveETH;
        require(tokenAmount > 0, "Bought amount too low");


        require(tokenAmount >= amountOutMin, "slippage reached");

        token.transfer(msg.sender, tokenAmount);

    }
    function sell(uint256 sellAmount, uint256 amountOutMin) public {
        require(
            lastTX[msg.sender] != block.number,
            "fuck u reentry atacker or mevbots"
        );

        lastTX[msg.sender] = uint32(block.number);

        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        uint256 ethAmount = (sellAmount * reserveETH) /
            (reserveToken + sellAmount);

        require(reserveETH >= ethAmount, "Insufficient ETH in reserves");

        uint256 feeAmount = (ethAmount * fee) / 10000;

        unchecked {
            ethAmount -= feeAmount;
        }
        require(ethAmount > 0, "Sell amount too low");
        require(ethAmount >= amountOutMin, "slippage reached");

        token.transfer(address(this), sellAmount);

        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        if (!success) {
            revert("Could not sell");
        }

    }
}