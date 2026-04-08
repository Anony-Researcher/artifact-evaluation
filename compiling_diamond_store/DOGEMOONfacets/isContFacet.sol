/**

Telegram: https://t.me/DogeMoonPortal

Twitter: https://twitter.com/DogeMoonERC20

Website: https://dogemoon.fun

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;
import "./TestLib.sol";
contract isContFacet {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function isCont(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
