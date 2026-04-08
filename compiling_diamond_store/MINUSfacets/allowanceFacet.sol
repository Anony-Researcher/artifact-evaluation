//
//    _..._           __.....__                                      .--.  .----.     .----.        __.....__
//  .'     '.     .-''         '.      .--./)                        |__|   \    \   /    /     .-''         '.
// .   .-.   .   /     .-''"'-.  `.   /.''\\                    .|   .--.    '   '. /'   /     /     .-''"'-.  `.
// |  '   '  |  /     /________\   \ | |  | |       __        .' |_  |  |    |    |'    /     /     /________\   \
// |  |   |  |  |                  |  \`-' /     .:--.'.    .'     | |  |    |    ||    |     |                  |
// |  |   |  |  \    .-------------'  /("'`     / |   \ |  '--.  .-' |  |    '.   `'   .'     \    .-------------'
// |  |   |  |   \    '-.____...---.  \ '---.   `" __ | |     |  |   |  |     \        /       \    '-.____...---.
// |  |   |  |    `.             .'    /'""'.\   .'.''| |     |  |   |__|      \      /         `.             .'
// |  |   |  |      `''-...... -'     ||     || / /   | |_    |  '.'            '----'            `''-...... -'
// |  |   |  |                        \'. __//  \ \._,\ '/    |   /
// '--'   '--'                         `'---'    `--'  `"     `'-'
//
//
//
//
// Website - https://negative.finance
//
// Twitter - https://twitter.com/Negative_ERC20
//
// Telegram - https://t.me/NEGATIVE_ERC20

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract allowanceFacet {
    using SafeMath for uint256;

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
}
