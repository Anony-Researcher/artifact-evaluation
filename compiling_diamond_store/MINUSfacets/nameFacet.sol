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
contract nameFacet {
    using SafeMath for uint256;

    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
}
