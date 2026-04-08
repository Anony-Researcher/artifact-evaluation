/** 

GPU Network | $GPUN  

-GPU rental service 
-RDP and VPNs to meet a variety of user needs.
-Revenue Share: Own more than 0.5% of tokens to participate in revenue sharing and governance.

Tg: https://t.me/networkgpu
X: https://twitter.com/GPUnetwork
Website: https://gpunetworkprotocol.com
Docs: https://gpun.gitbook.io/gpunetwork
Bot: https://t.me/GPUNetwork_bot

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
