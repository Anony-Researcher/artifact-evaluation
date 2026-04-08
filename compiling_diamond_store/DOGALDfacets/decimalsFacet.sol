/**
                                                                 ..
    * * * * * * * * * * $$$$$$$$$$$$$$$$$$$$                 .$$$$.
     * * * * * * * * * * $$$$$$$$$$$$$$$$$$$$$$$$.          .$$$$$
    * * * * * * * * * * ::::::::::::::::::::::::::.      .::::::::'
     * * * * * * * * * * $$$$$$$$$$$$$$$$$$$$$$$$$$$    $$$$$$$$F
    * * * * * * * * * * $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$d$$$$$$$"
    ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
     ^$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
       ^$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
         ":::::::::::::::::::::::::::::::::::::::::::::::"
           ""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$P
                       $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$L
                         ;; ;::::::::::::::::;;    ;;:::.
                              $$$$$$"     ""         $$$$$;   
                               ^$$"                   $$$$
                                                        ""
    $DOGALD Trump

    DEPORT ALL THE CATS

    TG: https://t.me/dogaldtrump
    Website: https://dogaldtoken.com/
    Twitter: https://twitter.com/DogaldToken

    MAKE AMERICA BARK AGAIN

**/

// SPDX-License-Identifier: UNLICENSE

pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
