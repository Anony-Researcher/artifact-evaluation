/**


                                               
████████╗██████╗ ██╗   ██╗███╗   ███╗██████╗ ███████╗    ██╗  ██╗ █████╗ ██╗██████╗ 
╚══██╔══╝██╔══██╗██║   ██║████╗ ████║██╔══██╗██╔════╝    ██║  ██║██╔══██╗██║██╔══██╗
   ██║   ██████╔╝██║   ██║██╔████╔██║██████╔╝███████╗    ███████║███████║██║██████╔╝
   ██║   ██╔══██╗██║   ██║██║╚██╔╝██║██╔═══╝ ╚════██║    ██╔══██║██╔══██║██║██╔══██╗
   ██║   ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║     ███████║    ██║  ██║██║  ██║██║██║  ██║
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝
                                                                                    
Trump's Hair is your ticket to becoming rich, as you know Trump's hair is worth 7 billion dollars.          



Website - https://trumpshair.vip/
Telegram - https://t.me/hairportal
Twitter - https://twitter.com/TrumpsHairERC


**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
