// SPDX-License-Identifier: UNLICENSE

/*

https://x.com/cb_doge/status/1763064298052415835?s=46

https://x.com/elonmusk/status/1763066394273255580?s=46

Elon's first ever twitter account

https://t.me/Bill_erc

*/

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
