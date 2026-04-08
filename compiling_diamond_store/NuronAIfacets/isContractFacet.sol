// SPDX-License-Identifier: MIT

/**
    Web      : https://nuronai.tech
    App      : https://app.nuronai.tech
    Docs     : https://docs.nuronai.tech

    Twitter  : https://twitter.com/nuronais
    Telegram : https://t.me/nuronaitech
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
