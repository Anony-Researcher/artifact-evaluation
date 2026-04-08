// SPDX-License-Identifier: UNLICENSE

/*
ʂղąքէօɾղ, The most fearsome creation from Matt Furie's ZOGZ, designed to be the Pepe killer

Matt Furie's tweet: https://twitter.com/Matt_Furie/status/1658240583809519616
https://opensea.io/assets/ethereum/0x808e5cd160d8819ca24c2053037049eb611d0542/53
https://t.me/snaptorn

**/

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
