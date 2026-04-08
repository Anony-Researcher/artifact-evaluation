// SPDX-License-Identifier: MIT
/*
    Twitter:    https://twitter.com/error
    Telegram:   https://t.me/errorerc404
    Website:    https://www.error.computer/
    
    ~Setting the standard on ERC-404.
*/
pragma solidity 0.8.24;
import "./TestLib.sol";
contract tokenURIFacet is ERC404 {
    function tokenURI(uint256 id) public view override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return string.concat(ds.baseTokenURI, Strings.toString(id));
    }
}
