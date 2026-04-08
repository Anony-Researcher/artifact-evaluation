/**

Lumina AI - $LUMINA

Website:       https://luminaai.xyz
Dapp:          https://app.luminaai.xyz
Twitter:       https://twitter.com/ai_lumina
Telegram:      https://t.me/luminaai_erc20
Medium:        https://medium.com/@luminaai_erc20

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
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
