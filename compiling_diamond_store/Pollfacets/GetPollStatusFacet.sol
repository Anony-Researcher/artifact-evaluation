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
contract GetPollStatusFacet {
    function GetPollStatus(
        uint40 rawPollIndex
    )
        external
        view
        returns (
            uint40 remainingTime,
            uint96 invalidTotal,
            uint96[14] memory voteSums
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.numPolls[rawPollIndex >> 37] > rawPollIndex & ((1 << 37) - 1),
            "bad rawPollIndex"
        );
        uint40 endTime = ds.pollOptionStates[rawPollIndex][1].pollEndTimestamp; // it's not yet remaining time, it's end time, we dual-purpose to avoid stack issues.

        // Debug:
        // if( endTime <= debug_time) {
        // Production:
        if (endTime <= block.timestamp) {
            remainingTime = 0;
        } else {
            // Debug:
            //remainingTime = uint40(endTime - debug_time);
            // Production:
            remainingTime = uint40(endTime - block.timestamp);
        }
        uint256 invalidTotal256 = 0;
        for (
            uint256 i = 0;
            i < uint256(ds.pollOptionStates[rawPollIndex][1].totalVoteOptions);
            ++i
        ) {
            voteSums[i] = ds.pollOptionStates[rawPollIndex][i].voteTotal;
            invalidTotal256 +=
                uint256(
                    ds
                    .pollOptionStates[rawPollIndex][i].invalidProposalVoteInGwei
                ) *
                1_000_000_000;
        }
        invalidTotal = uint96(invalidTotal256);
    }
}
