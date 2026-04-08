/**
          █████╗ ██████╗ ██████╗ ██╗     ███████╗██╗  ██╗███████╗ █████╗ ██████╗ 
         ██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝██║  ██║██╔════╝██╔══██╗██╔══██╗
         ███████║██████╔╝██████╔╝██║     █████╗  ███████║█████╗  ███████║██║  ██║
         ██╔══██║██╔═══╝ ██╔═══╝ ██║     ██╔══╝  ██╔══██║██╔══╝  ██╔══██║██║  ██║
         ██║  ██║██║     ██║     ███████╗███████╗██║  ██║███████╗██║  ██║██████╔╝
         ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
                                                                        
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract _burnTokensFacet {
    modifier onlyWhitelisted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.whiteList[msg.sender], "Caller is not whitelisted");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    function _burnTokens(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: burn from the zero address");
        require(
            ds._balances[account] >= amount,
            "ERC20: burn amount exceeds balance"
        );
        unchecked {
            ds._balances[account] -= amount;
            ds._totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
    }
    function burn(uint256 amount) external {
        _burnTokens(msg.sender, amount);
    }
}
