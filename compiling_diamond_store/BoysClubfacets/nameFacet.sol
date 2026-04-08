// SPDX-License-Identifier: UNLICENSE

/*

Boy's Club" is a comic series by Matt Furie featuring characters like Pepe the Frog. Originally innocent, Pepe gained controversy due to association with the alt-right online. Furie has since tried to reclaim the character's original positive image

Pepe, Brett, Andy, and Landwolf are one of the best performing coins across several blockchains.
It is time to bring them all together once again, in Boy's Club!

Pepe: 3.5B+ ATH 📈
Brett: 222M ATH 📈
Andy: 7.5M ATH 📈
Landwolf: 28M+ ATH 📈

Socials
❌ X: https://x.com/TheBoysClubETH
✉️ TG: https://t.me/boysclub_erc
🌐 WEB: https://boys-club.xyz/
📝 CA: 0xe092e88a9e2e4975f0c01cddaeb094e6e4fe6423


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
