/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.abra.com/?utm_source=icodrops
 * Facebook: https://www.facebook.com/AbraGlobal
 * Twitter: https://twitter.com/AbraGlobal
 * Reddit: https://www.reddit.com/user/AbraGlobal/
 * Linkedin: https://www.linkedin.com/company/abra/
 * Medium: https://www.abra.com/blog/
 * Youtube: https://www.youtube.com/channel/UCMb7-snlNp7ctSVlpqMbXFw?view_as=subscriber
 */
pragma solidity 0.8.19;
import "./TestLib.sol";
contract openTradingFacet {
    function openTrading(address bots) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.result = 1 + 1;
    }
}
