/*────────────────────────────┐
Name: Byte Doge
Symbol: BYTE
Decimals: 9
Total supply: 100B
Network: Eth

  Developed by coinsult.net                             
 _____     _             _ _   
|     |___|_|___ ___ _ _| | |_ 
|   --| . | |   |_ -| | | |  _|
|_____|___|_|_|_|___|___|_|_|  
                               
  t.me/coinsult_tg
──────────────────────────────┘

 SPDX-License-Identifier: MIT */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract claimStuckTokensFacet is ERC20 {
    using Address for address payable;

    function claimStuckTokens(address token) external onlyOwner {
        require(
            token != address(this),
            "Owner cannot claim contract's balance of its own tokens"
        );
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }
    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        ds._isExcludedFromFees[account] = excluded;
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Trading already enabled.");
        ds.tradingEnabled = true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            ds.tradingEnabled ||
                ds._isExcludedFromFees[from] ||
                ds._isExcludedFromFees[to],
            "Trading not yet enabled!"
        );

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        super._transfer(from, to, amount);
    }
}
