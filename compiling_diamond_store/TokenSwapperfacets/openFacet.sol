// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.19;
import "./TestLib.sol";
contract openFacet {
    function open(
        uint256 swapNumber,
        address _executor,
        address _openingToken,
        uint256 _tokensToOpen,
        address _closingToken,
        uint256 _tokensToClose,
        uint256 _expiry
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //sanity checks

        // check if swap number already used. use expiry from struct as reference
        if (ds.allSwaps[msg.sender][swapNumber].expiry > 0) {
            revert SwapNumberAlreadyUsed();
        }

        if (
            _expiry <= block.timestamp || _expiry > block.timestamp + 365 days
        ) {
            revert ExpiryDateNotWithinFutureYear();
        }

        if (_executor == address(0)) {
            revert AddressValueZeroOrInvalid();
        }

        if (_openingToken == address(0)) {
            revert AddressValueZeroOrInvalid();
        }

        if (_closingToken == address(0)) {
            revert AddressValueZeroOrInvalid();
        }

        if (_openingToken == _closingToken) {
            revert TokensAddressesCannotBeSame();
        }

        if (_tokensToOpen == 0) {
            revert TokenAmountCannotBeZero();
        }

        if (_tokensToClose == 0) {
            revert TokenAmountCannotBeZero();
        }

        //fetch details of swap
        TestLib.Swap memory swap = ds.allSwaps[msg.sender][swapNumber];

        //fill in new swap details
        swap = TestLib.Swap({
            executor: _executor,
            openingToken: _openingToken,
            tokensToOpen: _tokensToOpen,
            closingToken: _closingToken,
            tokensToClose: _tokensToClose,
            expiry: _expiry,
            status: TestLib.States.OPEN
        });

        //store swap details in storage
        ds.allSwaps[msg.sender][swapNumber] = swap;

        //transfer tokensToOpen from swap creator
        IERC20 token = IERC20(_openingToken);
        SafeERC20.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            _tokensToOpen
        );

        //emit event
        emit Opened(
            msg.sender,
            _executor,
            _openingToken,
            _tokensToOpen,
            _closingToken,
            _tokensToClose
        );

        return true;
    }
}
