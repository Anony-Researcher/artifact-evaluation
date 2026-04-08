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
contract incrementEvolutionsFacet {
    using Strings for uint256;

    function incrementEvolutions(uint256 tokenId) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.revealOwner, "not ds.revealOwner");
        if (ds.evolutions[tokenId] >= 0) {
            ds.evolutions[tokenId] = ds.evolutions[tokenId] + 1;
        }
    }
}
