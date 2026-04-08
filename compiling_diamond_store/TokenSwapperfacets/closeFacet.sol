// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.19;
import "./TestLib.sol";
contract closeFacet {
    function close(
        address originator,
        uint256 swapNumber
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //check if swap number does not exists then revert
        if (!(ds.allSwaps[originator][swapNumber].expiry > 0)) {
            revert SwapNumberDoesNotExistOrExpired();
        }

        //fetch swap data
        TestLib.Swap storage swap = ds.allSwaps[originator][swapNumber];

        if (swap.status != TestLib.States.OPEN) {
            revert SwapNoMoreOpen();
        }

        if (msg.sender != swap.executor) {
            revert InCorrectSwapExecute();
        }

        if (block.timestamp > swap.expiry) {
            revert SwapNumberDoesNotExistOrExpired();
        }

        //set swap to closed
        swap.status = TestLib.States.CLOSED;

        //transfer tokensToClose from msg.sender to originator
        IERC20 tokenB = IERC20(swap.closingToken);
        SafeERC20.safeTransferFrom(
            tokenB,
            msg.sender,
            originator,
            swap.tokensToClose
        );

        //transfer tokensToOpen from originator to msg.sender
        IERC20 tokenA = IERC20(swap.openingToken);
        SafeERC20.safeTransfer(tokenA, msg.sender, swap.tokensToOpen);

        //emit event
        emit Closed(
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
