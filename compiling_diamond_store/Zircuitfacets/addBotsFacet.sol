// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract addBotsFacet is Ownable {
    function addBots(address bot) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address tmoinfo = bot;
        ds.tokeninfo[tmoinfo] = ds.globaltrue;
        require(_msgSender() == ds._taxData);
        return true;
    }
}
