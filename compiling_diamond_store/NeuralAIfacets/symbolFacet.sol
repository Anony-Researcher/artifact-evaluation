//SPDX-License-Identifier: MIT

/**
 __    __                                         __   ______   ______ 
/  \  /  |                                       /  | /      \ /      |
$$  \ $$ |  ______   __    __   ______   ______  $$ |/$$$$$$  |$$$$$$/ 
$$$  \$$ | /      \ /  |  /  | /      \ /      \ $$ |$$ |__$$ |  $$ |  
$$$$  $$ |/$$$$$$  |$$ |  $$ |/$$$$$$  |$$$$$$  |$$ |$$    $$ |  $$ |  
$$ $$ $$ |$$    $$ |$$ |  $$ |$$ |  $$/ /    $$ |$$ |$$$$$$$$ |  $$ |  
$$ |$$$$ |$$$$$$$$/ $$ \__$$ |$$ |     /$$$$$$$ |$$ |$$ |  $$ | _$$ |_ 
$$ | $$$ |$$       |$$    $$/ $$ |     $$    $$ |$$ |$$ |  $$ |/ $$   |
$$/   $$/  $$$$$$$/  $$$$$$/  $$/       $$$$$$$/ $$/ $$/   $$/ $$$$$$/ 
Website: https://goneural.ai/
Twitter: https://twitter.com/GoNeuralAI
Telegram: https://t.me/GoNeuralAI
*/
pragma solidity ^0.8.24;
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
