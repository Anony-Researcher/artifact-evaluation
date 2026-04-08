/*
Website: https://meshwave.ai
Docs: https://docs.meshwave.ai
X: http://x.com/meshwaveai
Telegram : https://t.me/meshwaveai
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
