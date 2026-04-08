/**
PORT AI: Manage your portfolio like never before with our Intelligent Insights.

PORT AI is an AI-Powered Telegram Bot that helps your portfolio managements with 
user friendly interface easy to access anywhere!

██████╗  ██████╗ ██████╗ ████████╗ █████╗ ██╗
██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗██║
██████╔╝██║   ██║██████╔╝   ██║   ███████║██║
██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║██║
██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║██║
╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝

    Website: https://www.portaierc20.com/
    Telegram: https://t.me/PortAiErc20
    Twitter:  https://twitter.com/PortAIOfficial
    Bot : https://t.me/Port_AI_bot
    Gitbook : https://docs.portaierc20.com/

**/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
