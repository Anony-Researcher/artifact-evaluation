// SPDX-License-Identifier: Unlicensed

/*
Quiz AI gives you the ability to choose from our preselected trivia topics or you can create ANY trivia topic you want and our AI-powered bot will  generate a challenging trivia quiz tailored just for you, your friends or your crypto project's community.

You can play for money, rewards, tokens, whitelists and more. Choose from 3 different quiz modes: 

- Project Mode: A unique competition bot for your crypto project's community
- Group Mode: Test your skills against a group of users or friends
- Player vs. Player Mode: Challenge one other person to see who has the biggest brain.

Welcome to the next generation of Quiz and Trivia Competition Bots.

Web: https://quizai.fun
Tg: https://t.me/quiz_ai_erc_official
X: https://twitter.com/Quiz_AI_X
Bot: https://t.me/QuizBot
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isGuarded = true;
        _;
        ds._isGuarded = false;
    }

    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.name_;
    }
}
