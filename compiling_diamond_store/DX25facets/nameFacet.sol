/*
 * SPDX-License-Identifier: MIT
 * Website: https://dx25.com/
 * Twitter: https://twitter.com/dx25labs
 * Telegram: https://t.me/dx25labs
 * Discord: https://discord.com/invite/nPEvPssGPB*/
pragma solidity ^0.8.21;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
