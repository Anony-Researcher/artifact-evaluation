// SPDX-License-Identifier: MIT

/**
Telegram : https://t.me/Etherblocksportal 
Twitter : https://twitter.com/EtherblocksERC 
Website : https://www.ether-block.net/ 
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
