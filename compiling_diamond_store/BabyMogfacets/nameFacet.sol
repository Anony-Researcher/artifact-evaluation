//Telegram: https://t.me/bmogcoin

//Twitter: https://twitter.com/babymogcoineth

//Website: https://babymog.vip

// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.23;
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
