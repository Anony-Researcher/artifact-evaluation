// SPDX-License-Identifier: UNLICENSE

/*
         __  __  ____  _____  _____  _    _          _____ 
        |  \/  |/ __ \|  __ \|  __ \| |  | |   /\   |_   _|
        | \  / | |  | | |__) | |__) | |__| |  /  \    | |  
        | |\/| | |  | |  _  /|  ___/|  __  | / /\ \   | |  
        | |  | | |__| | | \ \| |    | |  | |/ ____ \ _| |_ 
        |_|  |_|\____/|_|  \_\_|    |_|  |_/_/    \_\_____|
                                                            
    https://morph.ai
    https://www.ed.ac.uk/bayes/accelerating-entrepreneurship/vbi/the-venture-builder-incubator-cohort-2022/morph-ai                              
*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
