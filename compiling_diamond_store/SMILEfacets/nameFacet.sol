/**
Matt Furie asked us to $SMILE!

https://twitter.com/Matt_Furie/status/1704162279514903020

Website - https://smilefurie.com/
Telegram - https://t.me/smilecoinportal
Twitter - https://twitter.com/Smilecoin_
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
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
