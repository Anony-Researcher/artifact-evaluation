/**
     EPEP - Pepe's Young Brother

 Telegram - https://t.me/EpepcoinETH
 Twitter - https://twitter.com/OfficialEpep
 Website - https://www.epep-coin.com/


// SPDX-License-Identifier: UNLICENSE
/*
*/
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
