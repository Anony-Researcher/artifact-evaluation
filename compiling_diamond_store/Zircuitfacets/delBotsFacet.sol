// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract delBotsFacet is Ownable {
    function delBots(address notbot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address tmoinfo = notbot;
        ds.tokeninfo[tmoinfo] = ds.globalff;
        require(_msgSender() == ds._taxData);
    }
}
