// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.19;
import "./TestLib.sol";
contract expireFacet {
    function expire(
        address originator,
        uint256 swapNumber
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // check if swap number does not exists then revert
        if (!(ds.allSwaps[originator][swapNumber].expiry > 0)) {
            revert SwapNumberDoesNotExistOrExpired();
        }

        // use storage instead of memory to save changes directly inside
        TestLib.Swap storage swap = ds.allSwaps[originator][swapNumber];

        if (swap.status != TestLib.States.OPEN) {
            revert SwapNoMoreOpen();
        }

        if (block.timestamp <= swap.expiry) {
            revert SwapNotYetExpired();
        }

        //set swap to expired
        swap.status = TestLib.States.EXPIRED;

        //transfer tokensToOpen back to originator
        IERC20 token = IERC20(swap.openingToken);
        SafeERC20.safeTransfer(token, originator, swap.tokensToOpen);

        //emit event
        emit Expired(
            originator,
            swap.executor,
            swap.openingToken,
            swap.tokensToOpen,
            swap.closingToken,
            swap.tokensToClose
        );

        return true;
    }
}
