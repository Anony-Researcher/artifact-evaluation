// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract initializeFacet is OwnableUpgradeableWithExpiry, Pausable {
    using SafeERC20 for IERC20;

    function initialize(
        // A unique identifier for this peggy instance to use in signatures
        bytes32 _peggyId,
        // How much voting power is needed to approve operations
        uint256 _powerThreshold,
        // The validator set, not in valset args format since many of it's
        // arguments would never be used in this case
        address[] calldata _validators,
        uint256[] calldata _powers
    ) external initializer {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        __Context_init_unchained();
        __Ownable_init_unchained();
        // CHECKS

        // Check that validators, powers, and signatures (v,r,s) set is well-formed
        require(
            _validators.length == _powers.length,
            "Malformed current validator set"
        );

        // Check cumulative power to ensure the contract has sufficient power to actually
        // pass a vote
        uint256 cumulativePower = 0;
        for (uint256 i = 0; i < _powers.length; i++) {
            cumulativePower = cumulativePower + _powers[i];
            if (cumulativePower > _powerThreshold) {
                break;
            }
        }

        require(
            cumulativePower > _powerThreshold,
            "Submitted validator set signatures do not have enough power."
        );

        ValsetArgs memory _valset;
        _valset = ValsetArgs(_validators, _powers, 0, 0, address(0));

        bytes32 newCheckpoint = makeCheckpoint(_valset, _peggyId);

        // ACTIONS

        ds.state_peggyId = _peggyId;
        ds.state_powerThreshold = _powerThreshold;
        ds.state_lastValsetCheckpoint = newCheckpoint;
        ds.state_lastEventNonce = ds.state_lastEventNonce + 1;
        // LOGS

        emit ValsetUpdatedEvent(
            ds.state_lastValsetNonce,
            ds.state_lastEventNonce,
            0,
            address(0),
            _validators,
            _powers
        );
    }
    function updateValset(
        // The new version of the validator set
        ValsetArgs calldata _newValset,
        // The current validators that approve the change
        ValsetArgs calldata _currentValset,
        // These are arrays of the parts of the current validator's signatures
        uint8[] calldata _v,
        bytes32[] calldata _r,
        bytes32[] calldata _s
    ) external whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // CHECKS

        // Check that the valset nonce is greater than the old one
        require(
            _newValset.valsetNonce > _currentValset.valsetNonce,
            "New valset nonce must be greater than the current nonce"
        );

        // Check that new validators and powers set is well-formed
        require(
            _newValset.validators.length == _newValset.powers.length,
            "Malformed new validator set"
        );

        // Check that current validators, powers, and signatures (v,r,s) set is well-formed
        require(
            _currentValset.validators.length == _currentValset.powers.length &&
                _currentValset.validators.length == _v.length &&
                _currentValset.validators.length == _r.length &&
                _currentValset.validators.length == _s.length,
            "Malformed current validator set"
        );

        // Check that the supplied current validator set matches the saved checkpoint
        require(
            makeCheckpoint(_currentValset, ds.state_peggyId) ==
                ds.state_lastValsetCheckpoint,
            "Supplied current validators and powers do not match checkpoint."
        );

        // Check that enough current validators have signed off on the new validator set
        bytes32 newCheckpoint = makeCheckpoint(_newValset, ds.state_peggyId);
        checkValidatorSignatures(
            _currentValset.validators,
            _currentValset.powers,
            _v,
            _r,
            _s,
            newCheckpoint,
            ds.state_powerThreshold
        );

        // ACTIONS

        // Stored to be used next time to validate that the valset
        // supplied by the caller is correct.
        ds.state_lastValsetCheckpoint = newCheckpoint;

        // Store new nonce
        ds.state_lastValsetNonce = _newValset.valsetNonce;

        // Send submission reward to msg.sender if reward token is a valid value
        if (
            _newValset.rewardToken != address(0) && _newValset.rewardAmount != 0
        ) {
            IERC20(_newValset.rewardToken).safeTransfer(
                msg.sender,
                _newValset.rewardAmount
            );
        }

        // LOGS
        ds.state_lastEventNonce = ds.state_lastEventNonce + 1;
        emit ValsetUpdatedEvent(
            _newValset.valsetNonce,
            ds.state_lastEventNonce,
            _newValset.rewardAmount,
            _newValset.rewardToken,
            _newValset.validators,
            _newValset.powers
        );
    }
    function submitBatch(
        // The validators that approve the batch
        ValsetArgs memory _currentValset,
        // These are arrays of the parts of the validators signatures
        uint8[] memory _v,
        bytes32[] memory _r,
        bytes32[] memory _s,
        // The batch of transactions
        uint256[] memory _amounts,
        address[] memory _destinations,
        uint256[] memory _fees,
        uint256 _batchNonce,
        address _tokenContract,
        // a block height beyond which this batch is not valid
        // used to provide a fee-free timeout
        uint256 _batchTimeout
    ) external nonReentrant whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // CHECKS scoped to reduce stack depth
        {
            // Check that the batch nonce is higher than the last nonce for this token
            require(
                ds.state_lastBatchNonces[_tokenContract] < _batchNonce,
                "New batch nonce must be greater than the current nonce"
            );

            // Check that the block height is less than the timeout height
            require(
                block.number < _batchTimeout,
                "Batch timeout must be greater than the current block height"
            );

            // Check that current validators, powers, and signatures (v,r,s) set is well-formed
            require(
                _currentValset.validators.length ==
                    _currentValset.powers.length &&
                    _currentValset.validators.length == _v.length &&
                    _currentValset.validators.length == _r.length &&
                    _currentValset.validators.length == _s.length,
                "Malformed current validator set"
            );

            // Check that the supplied current validator set matches the saved checkpoint
            require(
                makeCheckpoint(_currentValset, ds.state_peggyId) ==
                    ds.state_lastValsetCheckpoint,
                "Supplied current validators and powers do not match checkpoint."
            );

            // Check that the transaction batch is well-formed
            require(
                _amounts.length == _destinations.length &&
                    _amounts.length == _fees.length,
                "Malformed batch of transactions"
            );

            // Check that enough current validators have signed off on the transaction batch and valset
            checkValidatorSignatures(
                _currentValset.validators,
                _currentValset.powers,
                _v,
                _r,
                _s,
                // Get hash of the transaction batch and checkpoint
                keccak256(
                    abi.encode(
                        ds.state_peggyId,
                        // bytes32 encoding of "transactionBatch"
                        0x7472616e73616374696f6e426174636800000000000000000000000000000000,
                        _amounts,
                        _destinations,
                        _fees,
                        _batchNonce,
                        _tokenContract,
                        _batchTimeout
                    )
                ),
                ds.state_powerThreshold
            );

            // ACTIONS

            // Store batch nonce
            ds.state_lastBatchNonces[_tokenContract] = _batchNonce;

            {
                // Send transaction amounts to destinations
                uint256 totalFee;
                for (uint256 i = 0; i < _amounts.length; i++) {
                    IERC20(_tokenContract).safeTransfer(
                        _destinations[i],
                        _amounts[i]
                    );
                    totalFee = totalFee + _fees[i];
                }

                if (totalFee > 0) {
                    // Send transaction fees to msg.sender
                    IERC20(_tokenContract).safeTransfer(msg.sender, totalFee);
                }
            }
        }

        // LOGS scoped to reduce stack depth
        {
            ds.state_lastEventNonce = ds.state_lastEventNonce + 1;
            emit TransactionBatchExecutedEvent(
                _batchNonce,
                _tokenContract,
                ds.state_lastEventNonce
            );
        }
    }
    function sendToInjective(
        address _tokenContract,
        bytes32 _destination,
        uint256 _amount,
        string calldata _data
    ) external whenNotPaused nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(_tokenContract).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        ds.state_lastEventNonce = ds.state_lastEventNonce + 1;
        emit SendToInjectiveEvent(
            _tokenContract,
            msg.sender,
            _destination,
            _amount,
            ds.state_lastEventNonce,
            _data
        );
    }
    function emergencyPause() external onlyOwner {
        _pause();
    }
    function emergencyUnpause() external onlyOwner {
        _unpause();
    }
    function makeCheckpoint(
        ValsetArgs memory _valsetArgs,
        bytes32 _peggyId
    ) private pure returns (bytes32) {
        // bytes32 encoding of the string "checkpoint"
        bytes32 methodName = 0x636865636b706f696e7400000000000000000000000000000000000000000000;

        bytes32 checkpoint = keccak256(
            abi.encode(
                _peggyId,
                methodName,
                _valsetArgs.valsetNonce,
                _valsetArgs.validators,
                _valsetArgs.powers,
                _valsetArgs.rewardAmount,
                _valsetArgs.rewardToken
            )
        );
        return checkpoint;
    }
    function checkValidatorSignatures(
        // The current validator set and their powers
        address[] memory _currentValidators,
        uint256[] memory _currentPowers,
        // The current validator's signatures
        uint8[] memory _v,
        bytes32[] memory _r,
        bytes32[] memory _s,
        // This is what we are checking they have signed
        bytes32 _theHash,
        uint256 _powerThreshold
    ) private pure {
        uint256 cumulativePower = 0;

        for (uint256 i = 0; i < _currentValidators.length; i++) {
            // If v is set to 0, this signifies that it was not possible to get a signature from this validator and we skip evaluation
            // (In a valid signature, it is either 27 or 28)
            if (_v[i] != 0) {
                // Check that the current validator has signed off on the hash
                require(
                    verifySig(
                        _currentValidators[i],
                        _theHash,
                        _v[i],
                        _r[i],
                        _s[i]
                    ),
                    "Validator signature does not match."
                );

                // Sum up cumulative power
                cumulativePower = cumulativePower + _currentPowers[i];

                // Break early to avoid wasting gas
                if (cumulativePower > _powerThreshold) {
                    break;
                }
            }
        }

        // Check that there was enough power
        require(
            cumulativePower > _powerThreshold,
            "Submitted validator set signatures do not have enough power."
        );
        // Success
    }
    function verifySig(
        address _signer,
        bytes32 _theHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (bool) {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _theHash)
        );
        return _signer == ecrecover(messageDigest, _v, _r, _s);
    }
}
