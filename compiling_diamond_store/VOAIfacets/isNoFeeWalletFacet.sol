/***********************************************************************
//
//  
// ██╗   ██╗ ██████╗ ████████╗███████╗ ██████╗██╗  ██╗     █████╗ ██╗
// ██║   ██║██╔═══██╗╚══██╔══╝██╔════╝██╔════╝██║  ██║    ██╔══██╗██║
// ██║   ██║██║   ██║   ██║   █████╗  ██║     ███████║    ███████║██║
// ╚██╗ ██╔╝██║   ██║   ██║   ██╔══╝  ██║     ██╔══██║    ██╔══██║██║
//  ╚████╔╝ ╚██████╔╝   ██║   ███████╗╚██████╗██║  ██║    ██║  ██║██║
//   ╚═══╝   ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝
//
//                               
***********************************************************************/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract isNoFeeWalletFacet {
    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isNoFeeWallet(address account) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._noFee[account];
    }
}
