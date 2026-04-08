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
