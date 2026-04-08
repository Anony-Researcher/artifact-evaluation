//SPDX-License-Identifier: UNLICENSED
/*  
 * -- Welcome to Vision --
 *
 * CAREFUL, THIS CONTRACT IS ONLY A PROMOTIONAL CONTRACT. THE OFFICIAL VISION CONTRACT IS ALREADY OUT !
 * CHECK OUT OUR TG BELOW FOR MORE INFORMATION !
 *
 * Website: https://vision-scanner.com/
 * Telegram:  https://t.me/VisionPublic => Join our TG to have access to the bot :)
 * White paper:  https://vision-scanner.com/docs/
 * Twitter: https://twitter.com/Track_Vision_
 * Scam stat: https://vision-scanner.com/app/
 * 
 * VISION IS THE ULTIMATE SMART CONTRACT SCAM FILTER !
 * 
 * The only Telegram Bot that notifies you with safe & secure contracts on the ETH blockchain !
 * More than 90% of scams are filtered out !
 * Our team manually analyze new scams everyday and keep VISION up to date in order to protect your investements.
 * With unique features like our own backtesting algorithm, embrace security !
 * Stop losing money to rugpull and scams, use VISION bot now !
 */


pragma solidity ^0.8.0;

contract VISIONBOT {
    string public constant SYMBOL = "VISIONBOT";
    string public constant NAME = "Vision Scanner";
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 88888000 * (10 ** uint256(DECIMALS));

    mapping(address => uint256) private _balances;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        _balances[msg.sender] = TOTAL_SUPPLY;
        emit Transfer(address(0), msg.sender, TOTAL_SUPPLY);
    }

    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function name() public pure returns (string memory) {
        return NAME;
    }

    function symbol() public pure returns (string memory) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
}