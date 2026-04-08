//SPDX-License-Identifier: MIT

/*
 https://t.me/DLT_exchange 
 https://twitter.com/dlt_exchange
 https://dltexchange.co
*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract sellFeeFacet {
    modifier lockTaxSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    function sellFee() external view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._sellTaxrate;
    }
}
