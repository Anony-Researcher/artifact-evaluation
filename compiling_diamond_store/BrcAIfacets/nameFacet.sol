// SPDX-License-Identifier: MIT

/*
    Community : https://t.me/brcai_crypto_official

    Web  : https://brcai.us
    App  : https://app.brcai.us
    X    : https://x.com/BRCAI_CRYPTO
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
