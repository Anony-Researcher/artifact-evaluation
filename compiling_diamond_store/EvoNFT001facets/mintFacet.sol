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
contract mintFacet is ERC721Enumerable, Ownable {
    using Strings for uint256;

    function mint(uint256 _mintAmount) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 supply = totalSupply();
        require(!ds.paused);
        require(_mintAmount > 0);
        require(_mintAmount <= ds.maxMintAmount);
        require(supply + _mintAmount <= ds.maxSupply);

        if (msg.sender != owner()) {
            require(msg.value >= ds.cost * _mintAmount);
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }
}
