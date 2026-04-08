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
contract isContractFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
