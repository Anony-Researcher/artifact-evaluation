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
contract _baseURIFacet {
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

    function _baseURI() internal view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.uriPrefix;
    }
    function tokenURI(
        uint256 _tokenId
    ) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token."
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _tokenId.toString(),
                        ds.uriSuffix
                    )
                )
                : "";
    }
}
