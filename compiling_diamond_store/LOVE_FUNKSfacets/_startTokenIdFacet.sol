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
contract _startTokenIdFacet {
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

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
