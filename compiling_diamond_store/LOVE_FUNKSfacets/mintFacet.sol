// SPDX-License-Identifier: GPL-3.0

/*

##        #######  ##     ## ########    ######## ##     ## ##    ## ##    ##  ######  
##       ##     ## ##     ## ##          ##       ##     ## ###   ## ##   ##  ##    ## 
##       ##     ## ##     ## ##          ##       ##     ## ####  ## ##  ##   ##       
##       ##     ## ##     ## ######      ######   ##     ## ## ## ## #####     ######  
##       ##     ##  ##   ##  ##          ##       ##     ## ##  #### ##  ##         ## 
##       ##     ##   ## ##   ##          ##       ##     ## ##   ### ##   ##  ##    ## 
########  #######     ###    ########    ##        #######  ##    ## ##    ##  ######  

*/

pragma solidity ^0.8.13;
import "./TestLib.sol";
contract mintFacet {
    using Strings for uint256;

    modifier mintCompliance(uint256 _mintAmount) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.paused, "The contract is ds.paused!");
        require(
            _mintAmount > 0 && _mintAmount <= ds.maxPerTx,
            "Invalid mint amount!"
        );
        require(
            _mintAmount + ds.addressMintedBalance[msg.sender] <=
                ds.maxPerWallet,
            "Max per wallet exceeded!"
        );
        require(
            totalSupply() + _mintAmount <= ds.maxSupply,
            "Mint amount exceeds max supply!"
        );
        _;
    }

    function mint(
        uint256 _mintAmount
    ) public payable mintCompliance(_mintAmount) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            totalSupply() + _mintAmount <= ds.maxSupply,
            "Max supply limit exceeded!"
        );
        require(msg.value >= ds.cost * _mintAmount, "Insufficient funds!");

        ds.addressMintedBalance[msg.sender] += _mintAmount;
        _safeMint(_msgSender(), _mintAmount);
    }
}
