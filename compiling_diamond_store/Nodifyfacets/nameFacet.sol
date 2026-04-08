// SPDX-License-Identifier: Unlicensed

/**
Twitter: https://twitter.com/Nodify_cloud
Telegram: https://t.me/portalnodify
Website: https://www.nodify.cloud
Docs: https://whitepaper.nodify.cloud
**/
pragma solidity ^0.8.18;
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
