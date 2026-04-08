// SPDX-License-Identifier: MIT
/*
    Twitter:    https://twitter.com/error
    Telegram:   https://t.me/errorerc404
    Website:    https://www.error.computer/
    
    ~Setting the standard on ERC-404.
*/
pragma solidity 0.8.24;
import "./TestLib.sol";
contract setNameSymbolFacet is ERC404 {
    function setNameSymbol(
        string memory _name,
        string memory _symbol
    ) public onlyOwner {
        _setNameSymbol(_name, _symbol);
    }
}
