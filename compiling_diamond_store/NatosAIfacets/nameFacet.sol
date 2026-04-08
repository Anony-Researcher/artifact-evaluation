// SPDX-License-Identifier: MIT

/**
    Web     : https://natosai.com
    DApp    : https://app.natosai.com
    Docs    : https://docs.natosai.com

    Twitter : https://twitter.com/AInatos
    Telegram: https://t.me/natosaicash
*/

pragma solidity 0.8.19;
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
