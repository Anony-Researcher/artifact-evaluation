// SPDX-License-Identifier: UNLICENSE

/*
    ██████╗ ██╗██╗   ██╗███████╗ █████╗ ██████╗ ███╗   ███╗
    ██╔════╝ ██║██║   ██║██╔════╝██╔══██╗██╔══██╗████╗ ████║
    ██║  ███╗██║██║   ██║█████╗  ███████║██████╔╝██╔████╔██║
    ██║   ██║██║╚██╗ ██╔╝██╔══╝  ██╔══██║██╔══██╗██║╚██╔╝██║
    ╚██████╔╝██║ ╚████╔╝ ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║
    ╚═════╝ ╚═╝  ╚═══╝  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

    Giveth is rewarding and empowering those who give to projects, to society, and to the world!                                                                                                                                
    Stake tokens in the GIVfarm to grow your rewards.

    https://giveth.io/givfarm
    https://twitter.com/giveth
    https://discord.giveth.io/
    https://github.com/Giveth/
    https://www.youtube.com/givethio
    https://www.instagram.com/giveth.io/
    https://www.youtube.com/givethio
    https://reddit.com/r/giveth
    https://docs.giveth.io/

    by GIVeconomy 2024
*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
