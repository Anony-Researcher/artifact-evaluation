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
contract totalSupplyFacet {
    modifier onlyWhitelisted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.whiteList[msg.sender], "Caller is not whitelisted");
        _;
    }

    function totalSupply() external view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
}
