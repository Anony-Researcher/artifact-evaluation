/**

// SPDX-License-Identifier: MIT
/*

Telegram: https://t.me/GoofyInu_Portal

Twitter: https://twitter.com/Goofy_Inu_ETH

Website: https://www.goofy-inu.com/

*/
pragma solidity 0.8.25;
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
