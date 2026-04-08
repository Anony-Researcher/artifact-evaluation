// SPDX-License-Identifier: MIT

/**
Sentinel AI All In One
Security Solutions
The blockchain protocol is the base layer of the Web 3. The number of protocols and chains has increased. Blockchain cybersecurity is very important because a vulnerability in a single line of blockchain code can pose a huge risk to all projects built on top of it.
Sentinel AI is present fot Secure all layers of your architecture and protocol implementation with professional security auditing and testing
Secure your blockchain ecosystem with all in one security solution|
Protect your assets on all blockchain networks with our multi-chain support and advanced security features

Telegram: https://t.me/SentinelAiERC
Twitter: https://twitter.com/SentinelAiERC
Website: https://www.sentinel-ai.net/
Audit Website: http://audit.sentinel-ai.net/
Whitepaper: https://sentinel-ai-auditor.gitbook.io/sentinel-ai/
**/

pragma solidity 0.8.20;
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
