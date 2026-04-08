// SPDX-License-Identifier: MIT

/**

NOVA NETWORK
Revolutionizing Server and VPN Accessibility
NOVA NETWORK introduces a groundbreaking approach to server and VPN services.
Harnessing the power of advanced blockchain technology, NOVA offers a seamless, secure,
and swift digital infrastructure solution tailored to your needs.
Dive into a world where efficiency meets security.

Web : https://novanet.world/

DOCS = https://docs.novanet.world/

X = https://twitter.com/novanetworketh/

Telegram : https://t.me/novanetworkETH


**/

pragma solidity 0.8.20;
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
