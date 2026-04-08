// SPDX-License-Identifier: Unlicensed

// TG:  https://t.me/DuduERC
// X:   https://x.com/DuduCoinERC
// WEB: https://duducoin.com/

pragma solidity ^0.8.17;
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
