// SPDX-License-Identifier: MIT

/*
iziscan is a unique and replenished tool that functions as a telegram bot designed for more efficient and secure trading in the DeFi space.
Website: https://iziscan.io/
Twitter: https://twitter.com/izi24scan
Telegram Channel: https://t.me/Iziscan_official_channel
Official launch on the Uniswap exchange on March 2, 2024 at 20:00 UTC.
*/

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract include_in_feeFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "Ownable: caller is not the ds.owner");
        _;
    }

    function include_in_fee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = false;
    }
}
