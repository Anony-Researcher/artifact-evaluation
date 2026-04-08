//SPDX-License-Identifier: UNLICENSED
/**
         https://starheroes.io/

              https://twitter.com/StarHeroes_game       */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract checkEarlyBuyerFacet is ERC20 {
    using Address for address payable;

    modifier mutexLock() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._liquidityMutex) {
            ds._liquidityMutex = true;
            _;
            ds._liquidityMutex = false;
        }
    }

    function checkEarlyBuyer(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.isearlybuyer[account];
    }
}
