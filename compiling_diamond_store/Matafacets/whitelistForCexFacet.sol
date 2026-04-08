/**

Telegram : https://t.me/MataMemecoin

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract whitelistForCexFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event addressWhitelisted(address _address, bool _bool);
    function whitelistForCex(address _addr, bool _bool) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.deployerWallet,
            "Only team can call this function"
        );
        ds._isExcludedFromFee[_addr] = _bool;
        emit addressWhitelisted(_addr, _bool);
    }
}
