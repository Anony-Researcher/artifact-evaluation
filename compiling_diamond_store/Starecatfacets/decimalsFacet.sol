/**
 */
/**
//  ..________...___________........__........_______....._______....______.........__.......___________........______....___........____..____..._______...
//  ./".......).("....._...")....../""\....../"......\.../"....."|../"._.."\......./""\.....("....._...")....../"._.."\..|"..|......(".._||_.".|.|..._.."\..
//  (:...\___/...)__/..\\__/....../....\....|:........|.(:.______).(:.(.\___)...../....\.....)__/..\\__/......(:.(.\___).||..|......|...(..).:.|.(..|_)..:).
//  .\___..\........\\_./......../'./\..\...|_____/...)..\/....|....\/.\........./'./\..\.......\\_./..........\/.\......|:..|......(:..|..|...).|:.....\/..
//  ..__/..\\.......|...|.......//..__'..\...//....../...//.___)_...//..\._.....//..__'..\......|...|..........//..\._....\..|___....\\.\__/.//..(|.._..\\..
//  ./".\...:)......\:..|....../.../..\\..\.|:..__...\..(:......"|.(:..._).\.../.../..\\..\.....\:..|.........(:..._).\..(.\_|:..\.../\\.__.//\..|:.|_)..:).
//  (_______/........\__|.....(___/....\___)|__|..\___)..\_______)..\_______).(___/....\___).....\__|..........\_______)..\_______).(__________).(_______/..
//  ........................................................................................................................................................
www.starecat.io 
https://t.me/starecatgang

Join the New Cat Revolution

Token Total Supply Breakdown: 100 Billion 
Public Sale: 40% (40 billion STC) To encourage widespread distribution and foster a strong initial user base
Community Rewards and Airdrops: 15% (15 billion STC) Aimed at rewarding the community for engagement, contributions, and early support
Team and Founders: 10% (10 billion STC) Tokens will be locked for 1 year, followed by a vesting period of 24-36 months to align team incentives with the long-term success of the project
10% (10 billion STC) Reserved for future collaborations, partnerships, and fostering the ecosystem’s growth
Reserve: 10% (10 billion STC) Held for unforeseen opportunities or emergencies, with usage governed by community vote
Marketing and Promotion: 8% (8 billion STC) Dedicated to global marketing efforts, promotional events, and community building.
Research and Development: 7% (7 billion STC) To fund continuous product development, innovation, and technological advancements.

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
