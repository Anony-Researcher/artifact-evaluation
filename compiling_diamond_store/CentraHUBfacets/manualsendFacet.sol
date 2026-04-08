/**

Centrahub ($CTHUB) 
Keep in touch with us across various platforms:
Telegram : https://t.me/centrahubofficial
🌐Website: Centrahub - https://centrahub.io
Follow us on X for the latest updates: Centrahub on X : https://twitter.com/centrahublabs
📰Read our insights and news on Medium: Centrahub on Medium : https://medium.com/@centrahuberc
📄Connect with us on LinkedIn: CentraHub on LinkedIn : https://www.linkedin.com/in/centra-hub

Explore our website and join us on social media to stay informed about our innovative solutions and industry perspectives. Thank you for being part of the Centrahub community!

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;
import "./TestLib.sol";
contract manualsendFacet is ERC20 {
    using SafeMath for uint256;

    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
}
