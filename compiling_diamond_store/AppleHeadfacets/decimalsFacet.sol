/**
          █████╗ ██████╗ ██████╗ ██╗     ███████╗██╗  ██╗███████╗ █████╗ ██████╗ 
         ██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝██║  ██║██╔════╝██╔══██╗██╔══██╗
         ███████║██████╔╝██████╔╝██║     █████╗  ███████║█████╗  ███████║██║  ██║
         ██╔══██║██╔═══╝ ██╔═══╝ ██║     ██╔══╝  ██╔══██║██╔══╝  ██╔══██║██║  ██║
         ██║  ██║██║     ██║     ███████╗███████╗██║  ██║███████╗██║  ██║██████╔╝
         ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
                                                                        
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet {
    modifier onlyWhitelisted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.whiteList[msg.sender], "Caller is not whitelisted");
        _;
    }

    function decimals() external pure returns (uint8) {
        return DECIMAL;
    }
}
