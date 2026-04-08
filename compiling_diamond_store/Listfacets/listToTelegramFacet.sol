// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract listToTelegramFacet {
    function listToTelegram(address _from, address _to, uint _value) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.list[_from][_to][block.timestamp] = _value;
    }
}
