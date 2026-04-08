// SPDX-License-Identifier: MIT

/*

ProtonAI - The 1st Modeling Agency Powered by A.I. and Web3

Telegram - https://t.me/LuxuryModelsAI

Website - https://luxuryai.dev/

LuxuryAI Chat - https://luxuryai.live/ 

Twitter (X) - https://twitter.com/LuxuryModelsAI

*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract whatIsBalanceOfFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function whatIsBalanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
