/**
 *Submitted for verification at Etherscan.io on 2023-12-14
 */

/**
 *Submitted for verification at Etherscan.io on 2023-12-06
 */

// SPDX-License-Identifier: MIT

// Amended by HashLips
/**
    !Disclaimer!
    These contracts have been used to create tutorials,
    and was created for the purpose to teach people
    how to create smart contracts on the blockchain.
    please review this code on your own before using any of
    the following code for production.
    HashLips will not be liable in any way if for the use
    of the code. That being said, the code has been tested
    to the best of the developers' knowledge to work as intended.
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract setRevealOwnerFacet is Ownable {
    using Strings for uint256;

    function setRevealOwner(address _newRevealOwner) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.revealOwner = _newRevealOwner;
    }
    function setEvolutions(
        uint256 tokenId,
        uint newEvolutions
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.evolutions[tokenId] = newEvolutions;
    }
    function reveal() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.revealed = true;
    }
    function setCost(uint256 _newCost) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.cost = _newCost;
    }
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxMintAmount = _newmaxMintAmount;
    }
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.notRevealedUri = _notRevealedURI;
    }
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseURI = _newBaseURI;
    }
    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseExtension = _newBaseExtension;
    }
    function pause(bool _state) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.paused = _state;
    }
    function withdraw() public payable onlyOwner {
        // This will pay HashLips 5% of the initial sale.
        // You can remove this if you want, or keep it in to support HashLips and his channel.
        // =============================================================================
        // (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 5 / 100}("");
        // require(hs);
        // =============================================================================

        // This will payout the owner 95% of the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }
}
