/*
https://pipeprotocol.cash/
https://app.pipeprotocol.cash/
https://docs.pipeprotocol.cash/

https://t.me/pipeprotocol_official
https://twitter.com/ProtocolPipe
*/

// SPDX-License-Identifier: Unlicensed

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
