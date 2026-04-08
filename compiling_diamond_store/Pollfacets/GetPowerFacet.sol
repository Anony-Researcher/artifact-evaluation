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
contract GetPowerFacet {
    event PollPromotion(uint8 indexed votedPower, uint40 rawPollIndex);
    function GetPower(uint256 numVotes) private pure returns (uint8) {
        numVotes /= 1000000000000000000000000; // 1M with 18 decimals (27 zeros)
        if (numVotes == 0) {
            return 0;
        }
        if (numVotes < 3) {
            return 1;
        }
        if (numVotes < 10) {
            return 2;
        }
        if (numVotes < 30) {
            return 3;
        }
        if (numVotes < 100) {
            return 4;
        }
        if (numVotes < 300) {
            return 5;
        }
        return 6;
    }
    function CreatePollAndVote(
        TestLib.PollCreationOptionsStruct memory myPollCreationOptionsStruct,
        string calldata inputString,
        uint192 splitIndexes
    ) external returns (uint40 rawPollIndexUint40) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Here we assume the voteWeight is correct and only check it later at the end of the transaction.
        // If it is wrong, the failed transaction gas will be higher with this design, but
        // this reduces temporary variables and this function runs quickly into stackToDeep issues.
        // We use this all-in-one function so it is easier to manage creation of polls.

        TestLib.StackWorkaround memory myStack;

        myStack.numCreatorOptions = validateSplitIndices(
            bytes(inputString).length,
            splitIndexes
        );

        // Function has stack issues so we dual purpose this var which is votedPower and then rawPollIndex
        myStack.votedPower = GetPower(myPollCreationOptionsStruct.voteWeight);
        myStack.rawPollIndex = uint40(ds.numPolls[myStack.votedPower]);
        require(
            myStack.rawPollIndex < (1 << 37),
            "Deploy another poll contract."
        );

        ds.numPolls[myStack.votedPower] = myStack.rawPollIndex + 1;
        myStack.rawPollIndex |= uint40(uint256(myStack.votedPower) << 37); //These rawPollIndexes are hard to read but contain the votedPower
        //  inherently (in the high bits).
        // If you want an easier to read pollIndex, use prettyPollIndex;

        myStack.prettyPollIndex = uint40(ds.numPrettyPollIndexes);
        ds.numPrettyPollIndexes = myStack.prettyPollIndex + 1;
        ds.prettyPollIndexToRawPollIndex[myStack.prettyPollIndex] = myStack
            .rawPollIndex;
        ds.rawPollIndexToPrettyPollIndex[myStack.rawPollIndex] = myStack
            .prettyPollIndex;

        if (myPollCreationOptionsStruct.voteAsDelegate) {
            require(
                ds.delegationAcceptances[msg.sender] != address(0),
                "No delegation accepted"
            );
            emit NewPollCreated(
                ds.delegationAcceptances[msg.sender],
                myStack.votedPower,
                myStack.rawPollIndex,
                myStack.prettyPollIndex,
                inputString,
                splitIndexes,
                // Debug:
                //myPollCreationOptionsStruct.voteWeightTimestamp, uint40(debug_time), uint40(debug_time + myPollCreationOptionsStruct.duration));
                // Production:
                myPollCreationOptionsStruct.voteWeightTimestamp,
                uint40(block.timestamp),
                uint40(block.timestamp + myPollCreationOptionsStruct.duration)
            );
        } else {
            emit NewPollCreated(
                msg.sender,
                myStack.votedPower,
                myStack.rawPollIndex,
                myStack.prettyPollIndex,
                inputString,
                splitIndexes,
                // Debug:
                //myPollCreationOptionsStruct.voteWeightTimestamp, uint40(debug_time), uint40(debug_time + myPollCreationOptionsStruct.duration));
                // Production:
                myPollCreationOptionsStruct.voteWeightTimestamp,
                uint40(block.timestamp),
                uint40(block.timestamp + myPollCreationOptionsStruct.duration)
            );
        }

        AddPollOptionsAndVote(
            myStack.rawPollIndex,
            myStack.numCreatorOptions,
            myPollCreationOptionsStruct
        );

        // We will store hash on-chain and emit event with poll string & split info so it doesn't need to be stored on-chain
        // We emit the string in an event so we know it is available off-chain.  If someone wants to analyze
        // the text and options on-chain they can pass it in as an input to a different contract, as well as the hash
        // and rawPollIndex, to verify the passed string and splits are correct.
        ds.pollHashes[myStack.rawPollIndex] = keccak256(
            abi.encodePacked(inputString, splitIndexes, block.timestamp)
        ); // Include start of poll in the timestamp
        // because otherwise there is no way for
        // contracts to validate a poll submitted
        // by a different party conforms to some requirement
        // like which options are available, and that the
        // duration is sufficiently long.  In theory contracts
        // could want to verify the initial vote amount and the
        // address of the creator, but it's more likely that
        // those heavier use-cases will have the contract that
        // wants to observe a particular poll actually create
        // the poll or query a trusted contract that created the
        // poll.

        return myStack.rawPollIndex;
    }
    function validateSplitIndices(
        uint256 stringLength,
        uint256 splitIndexes
    ) private pure returns (uint8 numCreatorOptions) {
        uint256 prev = 0;
        numCreatorOptions = 0;
        for (uint256 i = 0; i < (12 * 16); i += 16) {
            uint256 current = (splitIndexes >> i) & 0xFFFF;
            if (current == 0) {
                require(i > 0, "No splits");
                return numCreatorOptions;
            } else {
                require(current > prev, "Decreasing order");
                require(current < stringLength, "Out of bounds index");
                // Every valid split is a creatorOption because total strings is
                // total splits + 1, and first string is poll, not creatorOption.
                ++numCreatorOptions;
                prev = current;
            }
        }
    }
    function AddPollOptionsAndVote(
        uint256 rawPollIndex,
        uint256 numCreatorOptions,
        TestLib.PollCreationOptionsStruct memory myPollCreationOptionsStruct
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        mapping(uint256 => TestLib.PollOptionState) storage myOptionStates = ds
            .pollOptionStates[rawPollIndex];
        // Don't forget 2 default options 0: Invalid Proposal and 1: Active Abstain
        uint256 timeStampToAnalze = myPollCreationOptionsStruct
            .voteWeightTimestamp;

        // Debug:
        // require(timeStampToAnalze >= MintOneStart, "Vote weight too early");
        // Production:
        require(timeStampToAnalze >= MintTwoEnd, "Vote weight too early");

        // DEBUG_TEST:
        require(
            timeStampToAnalze <= (block.timestamp - 15 minutes),
            "Vote weight too late"
        );
        // PRODUCTION_TEST:
        // PRODUCTION_LAUNCH:
        // require(timeStampToAnalze < (block.timestamp - 1 days), "Vote weight too late");

        // Debug:
        //timeStampToAnalze = debug_time + myPollCreationOptionsStruct.duration;
        // Production:
        timeStampToAnalze =
            block.timestamp +
            myPollCreationOptionsStruct.duration;

        // Debug:
        //require(timeStampToAnalze >= (debug_time + 7 days), "Poll ends too early"); // Minimum 7 days duration
        //require(timeStampToAnalze <= (debug_time + 28 days), "Poll ends too late"); // Max 28-day duration
        // Production
        require(
            timeStampToAnalze >= (block.timestamp + 7 days),
            "Poll ends too early"
        ); // Minimum 7 days duration
        require(
            timeStampToAnalze <= (block.timestamp + 28 days),
            "Poll ends too late"
        ); // Max 28-day duration

        // Skip 0 which is reserved
        // 1 is the Abstain Option index
        // 2 inclusive through 2 + numCreatorOptions, exclusive (so 2 through 1+numCreatorOptions inclusive) are the creatorOptions
        for (uint256 i = 1; i < numCreatorOptions + 2; ++i) {
            // We continue to reserve 0 option, option 1 is abstain, 2+ are creator options
            myOptionStates[i].totalVoteOptions = uint8(numCreatorOptions + 2);
            myOptionStates[i].voteWeightTimestamp = myPollCreationOptionsStruct
                .voteWeightTimestamp;

            // Debug:
            //myOptionStates[i].pollEndTimestamp = uint40(debug_time + myPollCreationOptionsStruct.duration);
            // Production:
            myOptionStates[i].pollEndTimestamp = uint40(
                block.timestamp + myPollCreationOptionsStruct.duration
            );
        }

        if (myPollCreationOptionsStruct.voteWeight != 0) {
            Vote(
                uint40(rawPollIndex),
                1,
                myPollCreationOptionsStruct.voteWeight,
                myPollCreationOptionsStruct.voteWeightIndex,
                false,
                myPollCreationOptionsStruct.voteAsDelegate
            );
        }
    }
    function Vote(
        uint40 rawPollIndex,
        uint8 pollChoice,
        uint96 voteWeight,
        uint64 voteWeightIndex,
        bool invalid,
        bool voteAsDelegate
    ) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(voteWeight > 0, "Can't vote zero");
        require(pollChoice != 0, "Zero option reserved");

        TestLib.PollOptionState storage myPollOptionStateStorage = ds
            .pollOptionStates[rawPollIndex][pollChoice];
        TestLib.PollOptionState
            memory myPollOptionState = myPollOptionStateStorage;
        require(
            pollChoice < myPollOptionState.totalVoteOptions,
            "Option out of bounds"
        );

        // Debug:
        //require(debug_time < uint256(myPollOptionState.pollEndTimestamp), "Too late to vote");
        // Production:
        require(
            block.timestamp < uint256(myPollOptionState.pollEndTimestamp),
            "Too late to vote"
        );

        bool isValid;
        uint96 validatedWeight;
        if (voteAsDelegate) {
            require(
                ds.delegationAcceptances[msg.sender] != address(0),
                "No delegation accepted."
            );
            (isValid, validatedWeight) = voteWeightSource
                .GetAndValidateVoteWeight(
                    ds.delegationAcceptances[msg.sender],
                    voteWeightIndex,
                    myPollOptionState.voteWeightTimestamp
                );
        } else {
            (isValid, validatedWeight) = voteWeightSource
                .GetAndValidateVoteWeight(
                    msg.sender,
                    voteWeightIndex,
                    myPollOptionState.voteWeightTimestamp
                );
        }

        require(isValid, "Invalid voteWeightIndex");
        if (validatedWeight == voteWeight) {
            // Candidate for simpleVote
            // Attempt to simple vote, i.e. one single vote of all available weight.  Gas-optimized

            // pollChoice+2 because here, 0 and 1 are not options but represent nonvoted and complex vote
            uint256 prevSimpleVoteState = GetSimpleVoteStateAndSetIfNotZero(
                rawPollIndex,
                pollChoice + 2,
                voteAsDelegate
            );
            require(prevSimpleVoteState == 0, "Can't vote max, already voted");
        } else {
            // Attempt to complex vote, i.e. possible to vote portions on same poll.
            // Gas-optimized for single-vote, and good for 2 votes.  Gas is not optimized for 3+ votes, 15k more gas
            //   than optimal design for that case.  This efficiently lets poll creators use some initial vote to
            //   avoid spam filter, and decide their later vote after community discourse (2 votes).  It also lets
            //    voters with very large vote weight efficiently vote only a small portion of their total and
            //   vote the rest as an abstain (something that could be interpreted as a gesture) or just not vote the rest.

            uint256 prevSimpleVoteState = GetSimpleVoteStateAndSetIfNotZero(
                rawPollIndex,
                1,
                voteAsDelegate
            );
            require(prevSimpleVoteState < 2, "Already voted max");
            ComplexVote(
                rawPollIndex,
                validatedWeight,
                voteWeight,
                pollChoice,
                voteAsDelegate
            ); // only succeeds if there was enough previously unvoted vote weight.
        }

        myPollOptionStateStorage.voteTotal =
            myPollOptionState.voteTotal +
            voteWeight;
        if (invalid) {
            myPollOptionStateStorage.invalidProposalVoteInGwei = uint72(
                uint256(myPollOptionState.invalidProposalVoteInGwei) +
                    (uint256(voteWeight) / 1_000_000_000)
            );
        }
        if (voteAsDelegate) {
            emit Voted(
                rawPollIndex,
                ds.delegationAcceptances[msg.sender],
                pollChoice,
                voteWeight,
                invalid
            );
        } else {
            emit Voted(
                rawPollIndex,
                msg.sender,
                pollChoice,
                voteWeight,
                invalid
            );
        }
    }
    function GetSimpleVoteStateAndSetIfNotZero(
        uint256 rawPollIndex,
        uint256 newSimpelVoteStateIfPrevZero,
        bool voteAsDelegate
    ) private returns (uint256 prevState) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // See above definition of ds.simpleVoteRecords for why it's done this way, to reduce gas of single votes of max weight,
        // with some resilience to spam/DOS of this optimization.
        uint256 rawPollIndexDiv64 = rawPollIndex / 64;
        uint256 withinWordIndex = (rawPollIndex % 64) * 4;
        uint256 simpleVoteRecord;
        if (voteAsDelegate) {
            require(
                ds.delegationAcceptances[msg.sender] != address(0),
                "No delegation accepted"
            );
            simpleVoteRecord = ds.simpleVoteRecords[
                ds.delegationAcceptances[msg.sender]
            ][rawPollIndexDiv64];
        } else {
            simpleVoteRecord = ds.simpleVoteRecords[msg.sender][
                rawPollIndexDiv64
            ];
        }
        prevState = (simpleVoteRecord >> withinWordIndex) & 0xF; // Get 4-bits at 256-bit word indexed 0-63.
        if (prevState == 0) {
            simpleVoteRecord =
                (simpleVoteRecord & (~(0xF << withinWordIndex))) |
                ((newSimpelVoteStateIfPrevZero & 0xF) << withinWordIndex);
            // small gas inefficiency anding newSimpelVoteStateIfPrevZero with 0xF, but makes clear and safe.
            if (voteAsDelegate) {
                ds.simpleVoteRecords[ds.delegationAcceptances[msg.sender]][
                    rawPollIndexDiv64
                ] = simpleVoteRecord;
            } else {
                ds.simpleVoteRecords[msg.sender][
                    rawPollIndexDiv64
                ] = simpleVoteRecord;
            }
        }
    }
    function ComplexVote(
        uint256 rawPollIndex,
        uint256 validatedWeight,
        uint256 voteWeight,
        uint256 pollChoice,
        bool voteAsDelegate
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.ComplexVoteRecord storage baseComplexVoteRecordStorage;
        if (voteAsDelegate) {
            require(
                ds.delegationAcceptances[msg.sender] != address(0),
                "No delegation available."
            );
            baseComplexVoteRecordStorage = ds.complexVoteRecords[
                ds.delegationAcceptances[msg.sender]
            ][rawPollIndex][0];
        } else {
            baseComplexVoteRecordStorage = ds.complexVoteRecords[msg.sender][
                rawPollIndex
            ][0];
        }
        TestLib.ComplexVoteRecord
            memory baseComplexVoteRecord = baseComplexVoteRecordStorage;
        uint256 newTotal = uint256(baseComplexVoteRecord.cumulativeVotes) +
            uint256(voteWeight);
        require(newTotal <= validatedWeight, "Exceeds user vote limit");
        baseComplexVoteRecordStorage.cumulativeVotes = uint96(newTotal);
        uint256 timesThisUserVotedThisPoll = baseComplexVoteRecord
            .timesThisUserVotedThisPoll;
        require(timesThisUserVotedThisPoll < (0xFFFFFFFF), "Too many votes"); //We are capping you at ~4B separate vote casts per poll lol.
        baseComplexVoteRecordStorage.timesThisUserVotedThisPoll = uint56(
            timesThisUserVotedThisPoll + 1
        );
        if (timesThisUserVotedThisPoll == 0) {
            baseComplexVoteRecordStorage.pollChoice = uint8(pollChoice);
            baseComplexVoteRecordStorage.voteWeightThisRecord = uint96(
                voteWeight
            );
        } else {
            TestLib.ComplexVoteRecord storage targetComplexVoteRecordStorage;
            if (voteAsDelegate) {
                targetComplexVoteRecordStorage = ds.complexVoteRecords[
                    ds.delegationAcceptances[msg.sender]
                ][rawPollIndex][timesThisUserVotedThisPoll];
            } else {
                targetComplexVoteRecordStorage = ds.complexVoteRecords[
                    msg.sender
                ][rawPollIndex][timesThisUserVotedThisPoll];
            }
            targetComplexVoteRecordStorage.pollChoice = uint8(pollChoice);
            targetComplexVoteRecordStorage.voteWeightThisRecord = uint96(
                voteWeight
            );
        }
    }
    function PromotePoll(uint8 newVotedPower, uint40 rawPollIndex) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 prevPower = ds.promotionLevel[rawPollIndex];
        if (prevPower >= newVotedPower) {
            return;
        }
        require(
            ds.numPolls[rawPollIndex >> 37] > rawPollIndex & ((1 << 37) - 1),
            "bad rawPollIndex"
        );
        // Debug:
        //require( ds.pollOptionStates[rawPollIndex][1].pollEndTimestamp > debug_time, "poll over");
        // Production:
        require(
            ds.pollOptionStates[rawPollIndex][1].pollEndTimestamp >
                block.timestamp,
            "poll over"
        );

        uint256 sum = 0;
        for (
            uint256 i = 0;
            i < uint256(ds.pollOptionStates[rawPollIndex][1].totalVoteOptions);
            ++i
        ) {
            sum += ds.pollOptionStates[rawPollIndex][i].voteTotal;
        }
        uint256 votedPower = GetPower(sum);
        if (votedPower > uint256(rawPollIndex >> 37)) {
            if (votedPower > prevPower) {
                if (votedPower >= newVotedPower) {
                    ds.promotionLevel[rawPollIndex] = votedPower;
                    emit PollPromotion(uint8(votedPower), rawPollIndex);
                }
            }
        }
    }
}
