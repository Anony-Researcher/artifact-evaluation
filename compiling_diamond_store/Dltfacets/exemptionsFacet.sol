//SPDX-License-Identifier: MIT

/*
 https://t.me/DLT_exchange 
 https://twitter.com/dlt_exchange
 https://dltexchange.co
*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract exemptionsFacet {
    modifier lockTaxSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    function exemptions(
        address wallet
    ) external view returns (bool fees, bool limits) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._nofee[wallet], ds._nolimit[wallet]);
    }
}
