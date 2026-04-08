// SPDX-License-Identifier: MIT

/*
    Web     : https://metasaviorai.tech
    App     : https://app.metasaviorai.tech
    Docs    : https://docs.metasaviorai.tech

    Twitter : https://x.com/metasaviorai
    Telegram: https://t.me/metasavioraigroup
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
