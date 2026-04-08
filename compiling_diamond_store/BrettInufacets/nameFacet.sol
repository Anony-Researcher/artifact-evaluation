/**

// SPDX-License-Identifier: MIT
/*

Telegram: https://t.me/BrettInu_Portal
Twitter: https://twitter.com/BrettInu_ETH
Website: https://www.brett-inu.com/

*/
pragma solidity 0.8.25;
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
