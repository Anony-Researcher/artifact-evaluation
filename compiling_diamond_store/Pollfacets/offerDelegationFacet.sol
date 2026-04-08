// SPDX-License-Identifier: MIT

/*
MIT License

Copyright (c) 2024 Cat Church LLC (see CCC.meme)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract offerDelegationFacet {
    function offerDelegation(address offerDelegationTo) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        cancelDelegationOffer();
        ds.delegationOffers[msg.sender] = offerDelegationTo;
    }
    function cancelDelegationOffer() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address previousOffer = ds.delegationOffers[msg.sender];
        if (previousOffer != address(0)) {
            ds.delegationOffers[msg.sender] = address(0);
            if (ds.delegationAcceptances[previousOffer] == msg.sender) {
                ds.delegationAcceptances[previousOffer] = address(0);
            }
        }
    }
}
