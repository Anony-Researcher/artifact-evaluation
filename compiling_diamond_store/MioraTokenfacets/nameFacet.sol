/**
    
    MIORA CHAIN is the evolution of blockchain, 
    By infusing AI directly into our Layer 1 infrastructure,
    We unlock unprecedented levels of efficiency, intelligent decision-making,
    and self-optimizing security.

    Dapp          : https://swap.miora.network/
    Website       : https://miora.network/
    Telegram      : https://t.me/miorachain
    X             : https://twitter.com/miorachain
    Docs          : https://docs.miora.network/miorachain
    
**/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.20;
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
