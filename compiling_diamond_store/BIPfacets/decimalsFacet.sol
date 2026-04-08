/**

Bibble Pool - $BIP

https://www.bibblepool.xyz
https://app.bibblepool.xyz
https://docs.bibblepool.xyz

https://t.me/bibblepool
https://twitter.com/bibblepool

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
