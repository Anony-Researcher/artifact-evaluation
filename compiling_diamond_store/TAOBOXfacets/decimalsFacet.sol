/*
TAOBOX - Revolutionizing AI Development
Our SDK Sandbox, enhanced by TAO (Bittensor), provides a dynamic and scalable environment for developers to innovate and refine AI models. 
Experience a suite of features designed to bring your AI applications closer to the decentralized reality of tomorrow.
WEB | https://taobox.tech
TG  | https://t.me/TaoBoxPortal
X   | https://twitter.com/TaoBox_ERC20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
