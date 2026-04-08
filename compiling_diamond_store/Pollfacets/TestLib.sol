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

interface IVoteWeightSource {
    // Function to get the index and vote weight based on a timestamp
    function GetIndexAndVoteWeight(
        address user,
        uint40 inputTimestamp
    ) external view returns (bool isValid, uint64 index, uint256 voteWeight);

    // Low gas alternative to GetIndexAndVoteWeight for validating and retrieving vote weight
    function GetAndValidateVoteWeight(
        address user,
        uint64 indexUint64,
        uint40 inputTimestampUint40
    ) external view returns (bool isValid, uint96 voteWeight);
}

// votedPower is 0 if < 1M votes, else 1 if < 3M votes, else 2 if less than 10M votes,
//   else 3 if < 30M, else 4 if < 100M, else 5 if < 300M, else 6.  Thus voted power is sort of like a decibels metric.
// Hopefully this enables efficient spam filtration and also polls that start with high votePower have higher
// pollNumber. (top 3 bits of 40-bit number are the initial votedPower upon creation,
// if creator both creates the poll and votes on it in one transaction).  There is a gas optimization
// for voters that vote on polls and they voted on recent polls of the same votePower.  Therefore it
// can cost less to vote on polls that start off above the spam filter (e.g. at least above 0 in power).
// Which helps facilitate more voting by reducing gas costs of those votes.  This is because
// the cheapest way to vote will be to vote all votePower in a single vote, these vote records will
// be stored in-order in an array indexed by the votePower.  The voteRecord is only the 4-bits of which
// which option was chosen (add 1 to it, so it is non-zero for true vote).  So a 256-bit word can
// hold 64 votes.

// votedOption has 1 of 16 values:
// 0 means unvoted
// 1 means voted through the partial-vote mechanism
// 2 means Reserved/(Previosly used for Invalid Proposal) (Option 0)
// 3 means Active Abstain (Option 1)
// 4 means Poll Creator-defined Option 0 (Option 2)
// 5 means Poll Creator-defined option 1 (Option 3)
// 6 means Poll Creator-defined option 2 (Option 4)
// 7 means Poll Creator-defined option 3 (Option 5)
// 8 means Poll Creator-defined option 4 (Option 6)
// 9 means Poll Creator-defined option 5 (Option 7)
// 10 means Poll Creator-defined option 6 (Option 8)
// 11 means Poll Creator-defined option 7 (Option 9)
// 12 means Poll Creator-defined option 8 (Option 10)
// 13 means Poll Creator-defined option 9 (Option 11)
// 14 means Poll Creator-defined option 10 (Option 12)
// 15 means Poll Creator-defined option 11 (Option 13)

// We will not actually let people vote Invalid Proposal explicitly, since we have changed the
// design to use a flag so any vote can also vote invalid proposal.  But we keep Invalid Proposal
// reserved here in case we need a flag late in design and don't want to have to change so much code.

// The vote weight that is voted can be read from the voteWeight contract so
// the amount voted does not need to be stored when full vote weight is being voted.

// The sum gas for votes at votePowers the voter has previously voted on, where the voter votes
// frequently on votes of that vote power is 21k (base transaction) + ~5200 (Get and Verify voteWeight)
// plus read and modify non-zero storage (5100) (check if already voted) plus read and modify non-zero storage
// (5100) (update vote total for selected options), plus some extra calldata (~200), plus emitting an event (~700).
// Thus, gas is trending for frequent voters on polls with non-spammed votePowers, of 37,300.  So less than 2x the minimum (< 42k)

address constant _voteWeightSourceAddress = 0x3871F0d0396Dbad8E970C274A7Ed8A2Ffb5B6EC1;
IVoteWeightSource constant voteWeightSource = IVoteWeightSource(
    _voteWeightSourceAddress
);
uint256 constant MintTwoEnd = 1712527200;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct ComplexVoteRecord {
        // First two here are overall records for this user and poll.  We put them in this struct to save gas.
        // This design is pretty efficient for people who will vote one vote less than their max, or two votes of any kind.
        // At 3+ votes it gets a little gas inefficient but that is niche use-case and its only ~15k more gas for such users for votes 3+.
        uint56 timesThisUserVotedThisPoll; // Only used in first index (0), i.e. complexVoteRecords[user address][pollIndex][0]
        uint96 cumulativeVotes; // Only used in first index (0), i.e. complexVoteRecords[user address][pollIndex][0]
        uint96 voteWeightThisRecord;
        uint8 pollChoice; // Same values 0-13 as described above.  reserved, abstain, and poll creator options 0-11;
    }
    struct PollOptionState {
        uint96 voteTotal;
        uint8 totalVoteOptions; // This is 2+ total creator  options (0 is reserved, 1 is Active Abstain)
        uint40 voteWeightTimestamp;
        uint40 pollEndTimestamp;
        uint72 invalidProposalVoteInGwei; // When user votes, we divide their vote by gwei (1 billion) to tally this number.
        // since we don't have quite enough bits to hold 18 decimals, we just hold 9.
        // We could hold 3 more decimals but we prefer Shannon to Lovelace ;-)
    }
    struct PollCreationOptionsStruct {
        // uint8 pollChoice; // We force poll choice to be abstain in this case since it is intended as a spam filter and it is
        // a stronger indicator of signal/noise if the creator is willing to be unbiased in their vote
        // they perform simultaneously with the poll creation.
        uint96 voteWeight;
        uint64 voteWeightIndex;
        uint40 voteWeightTimestamp; //must be greater than or equal to MintTwoEnd and ~less than block.timestamp - 15 minutes.
        uint40 duration; // Used to be pollEndTimestamp but instead it has been made a duration since it could
        // take a long time for a transaction to get added to a block and we don't want the end
        // timestamp to be invalid due to it taking a while for the transaction to be added to  block.
        // Minimum duration for
        bool voteAsDelegate;
    }
    struct StackWorkaround {
        uint8 votedPower;
        uint40 rawPollIndex;
        uint40 prettyPollIndex;
        uint8 numCreatorOptions;
    }

    struct TestStorage {
        mapping(address => address) delegationOffers;
        mapping(address => address) delegationAcceptances;
        mapping(uint256 => uint256) numPolls;
        mapping(address => mapping(uint256 => uint256)) simpleVoteRecords;
        uint256 numPrettyPollIndexes;
        mapping(uint256 => uint256) prettyPollIndexToRawPollIndex;
        mapping(address => mapping(uint256 => mapping(uint256 => undefined))) complexVoteRecords;
        mapping(uint256 => uint256) rawPollIndexToPrettyPollIndex;
        mapping(uint256 => mapping(uint256 => undefined)) pollOptionStates;
        mapping(uint256 => bytes32) pollHashes;
        mapping(uint256 => uint256) promotionLevel;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
