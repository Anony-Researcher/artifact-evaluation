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
contract mintToAddressFacet is Ownable {
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

    function mintToAddress(
        uint256 _mintAmount,
        address _receiver
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            totalSupply() + _mintAmount <= ds.maxSupply,
            "Mint amount exceeds max supply!"
        );
        _safeMint(_receiver, _mintAmount);
    }
    function MassAirdrop(
        uint256 amount,
        address[] calldata _receivers
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < _receivers.length; ++i) {
            require(
                totalSupply() + amount <= ds.maxSupply,
                "Max supply exceeded!"
            );
            _safeMint(_receivers[i], amount);
        }
    }
    function setMaxSupply(uint256 _MaxSupply) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxSupply = _MaxSupply;
    }
    function setCost(uint256 _cost) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.cost = _cost;
    }
    function setMaxPerTx(uint256 _maxPerTx) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxPerTx = _maxPerTx;
    }
    function setMaxPerWallet(uint256 _maxPerWallet) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxPerWallet = _maxPerWallet;
    }
    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uriPrefix = _uriPrefix;
    }
    function pause() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.paused == true) {
            ds.paused = false;
        } else {
            ds.paused = true;
        }
    }
    function reveal() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.revealed == true) {
            ds.revealed = false;
        } else {
            ds.revealed = true;
        }
    }
    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC721A, IERC721A) onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }
    function approve(
        address operator,
        uint256 tokenId
    ) public override(ERC721A, IERC721A) onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
    function withdraw() public onlyOwner nonReentrant {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}
