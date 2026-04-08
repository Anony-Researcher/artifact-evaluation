// SPDX-License-Identifier: MIT
/*
    Twitter:    https://twitter.com/error
    Telegram:   https://t.me/errorerc404
    Website:    https://www.error.computer/
    
    ~Setting the standard on ERC-404.
*/
pragma solidity 0.8.24;
import "./TestLib.sol";
contract setTokenURIFacet {
    function setTokenURI(string memory _tokenURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseTokenURI = _tokenURI;
    }
}
