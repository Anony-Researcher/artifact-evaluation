/**
// SPDX-License-Identifier: UNLICENSE

https://t.me/CybertruckonHoth_erc
https://twitter.com/elonmusk/status/1765274428441559530

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
