// SPDX-License-Identifier: MIT

/**
      - JUST IN -

https://justintoken.vip/
https://t.me/Justinportal
https://twitter.com/TokenJUSTIN
**/

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
