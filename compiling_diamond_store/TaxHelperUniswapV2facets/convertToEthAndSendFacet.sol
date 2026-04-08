// Sources flattened with hardhat v2.19.5 https://hardhat.org

// SPDX-License-Identifier: MIT

// File contracts/interfaces/IERC20.sol

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.24;
import "./TestLib.sol";
contract convertToEthAndSendFacet is Ownable {
    event SentEth(address wallet, uint256 amount);
    function convertToEthAndSend(
        address token,
        address[] memory walletsWithTax,
        uint256[] memory percentages,
        uint256 DENOMINATOR,
        uint256 maxThresholdSell
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.approvedTokens[msg.sender] && msg.sender != owner())
            revert TokenNotApproved(msg.sender);

        IERC20 tokenContract = IERC20(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        if (balance > maxThresholdSell) {
            balance = maxThresholdSell;
        }
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(ds.routerAddress);
        tokenContract.approve(address(uniswapRouter), balance);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswapRouter.WETH();
        if (balance > 0) {
            uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                balance,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );

            uint256 ethBalance = address(this).balance;
            emit ConvertedToEth(
                token,
                balance,
                walletsWithTax,
                percentages,
                DENOMINATOR,
                ethBalance
            );
            for (uint256 i = 0; i < walletsWithTax.length; ++i) {
                uint256 amountToSend = (ethBalance * percentages[i]) /
                    DENOMINATOR;
                payable(walletsWithTax[i]).transfer(amountToSend);
                emit SentEth(walletsWithTax[i], amountToSend);
            }
        }
    }
}
