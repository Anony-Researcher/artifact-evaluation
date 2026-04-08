//SPDX-License-Identifier: MIT

//Telegram: https://t.me/eclipsecoin
// Twitter: https://twitter.com/eclipse
// Website: https://eclipse2024coin.io
// Discord: https://discord.com/invite/Va58aMrcwk

pragma solidity ^0.5.8;
import "./TestLib.sol";
contract transferFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            amount <= ds._balances[from],
            "ERC20: transfer amount exceeds balance"
        );

        uint256 taxAmount = calculateTaxAmount(amount);
        uint256 tokensToTransfer = amount - taxAmount;

        ds._balances[from] -= amount;
        ds._balances[to] += tokensToTransfer;
        ds._balances[owner] += taxAmount;

        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, owner, taxAmount);
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function _spendAllowance(
        address ownerAddr,
        address spender,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ownerAddr != address(0),
            "ERC20: transfer from the zero address"
        );
        require(spender != address(0), "ERC20: transfer to the zero address");

        uint256 currentAllowance = ds._allowances[ownerAddr][spender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

        _approve(ownerAddr, spender, currentAllowance - amount);
    }
    function _approve(
        address ownerAddr,
        address spender,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ownerAddr != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[ownerAddr][spender] = amount;
        emit Approval(ownerAddr, spender, amount);
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function calculateTaxAmount(
        uint256 amount
    ) internal pure returns (uint256) {
        return (amount * SELL_TAX_PERCENT) / 100;
    }
}
