// SPDX-License-Identifier: UNLICENSE

/*

Decrypt, a versatile platform, facilitates server and VPN purchases through its bot and DApp interfaces. It prioritizes security with robust encryption, ensuring data confidentiality. The platform boasts powerful servers and fast VPNs, continually improving to meet evolving demands.

Users should choose Decrypt for their server and VPN needs because of its simplicity, security, and convenience. On the DApp, users can sign up easily via MetaMask and purchase servers and VPNs, ensuring a secure and straightforward process. Meanwhile, on the bot, users can instantly buy servers without the need for sign-up hassles; they can simply make payments and get what they need, making it quick and effortless. Whether through the DApp or bot, Decrypt offers a seamless experience tailored to different user preferences and needs.

✅ Safe Transactions: The tough security keeps your data safe.

✅ Super Speed: The servers and VPNs work really fast.

✅ User-Friendly Interface: Streamlined bot and advanced DApp features simplify procurement processes.

-Telegram: https://t.me/DecryptErc
-Twitter: https://twitter.com/DECRYPTErc
➡️Website: https://decrypt.sbs/
➡️Bot: https://t.me/DecryptErcBot
➡️DApp: https://web.decrypt.sbs/
➡️WhitePaper: https://docs.decrypt.sbs/

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
