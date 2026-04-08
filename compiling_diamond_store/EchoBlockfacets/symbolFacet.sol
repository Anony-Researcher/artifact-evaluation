/**
 *Submitted for verification at Etherscan.io on 2024-03-29
 */

/**
 *Submitted for verification at Etherscan.io on 2024-03-29
 */

// SPDX-License-Identifier: MIT
/** 
Telegram: https://t.me/echoblockerc20
Website: https://echoblock.org/
Twitter: https://twitter.com/EchoBlockerc20
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
