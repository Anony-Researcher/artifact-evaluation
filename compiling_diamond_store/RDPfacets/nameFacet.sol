// SPDX-License-Identifier: UNLICENSE

/*

At RemoteHub, we're on a mission to make remote desktop access simple, secure, and convenient for everyone. Powered by $RDP and built on a decentralized platform, we offer instant access, transparent transactions, and 24/7 availability.

RemoteHub, security is paramount. Our decentralized platform leverages blockchain technology to ensure transparent and secure transactions, safeguarding user data and autonomy in every interaction.

RemoteHub is your partner in navigating the evolving landscape of remote work. Say goodbye to cumbersome sign-up processes and hello to a world of seamless RDP solutions. Welcome to RemoteHub – where remote access meets simplicity, security, and sensation.

🟠Features: 

1. Instant Access: RemoteHub provides immediate access to remote desktop plans without cumbersome sign-up processes, ensuring users can start working or connecting remotely without delay.

2. Decentralized Platform: As a decentralized platform, RemoteHub offers enhanced security and autonomy in transactions, leveraging blockchain technology to ensure transparent and secure transactions for its users.

✅Website: https://remotehub.cloud/
⚡️DApp: https://rdp.remotehub.cloud/
🔒Docs: https://docs.remotehub.cloud/
📰Medium: https://remote-hub.medium.com/
✈️Telegram: https://t.me/remotehub_eth
🐦Twitter: https://twitter.com/RemoteHubErc
📹Youtube: https://www.youtube.com/watch?v=fiYTKqJSUlA

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
