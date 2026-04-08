// SPDX-License-Identifier: UNLICENSE

/*

MinerDock makes Ethereum mining easy for everyone. With our cloud mining platform, you can mine Ethereum without needing expensive hardware or tech skills. Our DApp is efficient, fosters community, and stays updated with the latest mining tech.

Currently, MinerDock's DApp is operational, providing a seamless experience for Ethereum mining. Presently, we offer four types of miners to cater to various user needs. Looking ahead, we aim to expand our offerings by introducing more diverse and efficient miners to enhance the mining experience further. Stay tuned for exciting updates as we continue to evolve and innovate in the world of cryptocurrency mining.

🦊 Features of MinerDock's DApp:

1. Efficient Mining: Our DApp optimizes mining for maximum returns without complexity.
2. Community Engagement: Engage with fellow miners for knowledge-sharing within our platform.
3. Cutting-Edge Updates: Stay ahead with regular updates, ensuring access to the latest mining technology.

⚡️⚡️Links: 

🔹Website: https://minerdock.net/
🔹DApp: https://store.minerdock.net/
📔Documenation: https://learn.minerdock.net/
✉️Telegram: https://t.me/minerdock
❌Twitter: https://twitter.com/MinerDock
📰Medium: https://minerdock.medium.com/


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
