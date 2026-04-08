// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./TestLib.sol";
contract addNewDexRouterFacet is ERC20 {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwapAndLiquify = true;
        _;
        ds._inSwapAndLiquify = false;
    }

    event NewRouterAdded(
        address indexed routerAddress,
        address indexed pairAddress
    );
    event DexPairStatusChanged(address indexed pair, bool status);
    event DevelopmentWalletChanged(
        address indexed oldWallet,
        address indexed newWallet
    );
    event TaxExclusionUpdated(address indexed account, bool indexed isExcluded);
    function addNewDexRouter(address routerAddress) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IDexV2Router newRouter = IDexV2Router(routerAddress);
        address newPair;
        try
            IDexV2Factory(newRouter.factory()).createPair(
                address(this),
                newRouter.WETH()
            )
        {} catch {}
        newPair = IDexV2Factory(newRouter.factory()).getPair(
            address(this),
            newRouter.WETH()
        );
        ds.dexPairStatus[newPair] = true;
        ds.pairToRouter[newPair] = routerAddress;
        ds.routerToPair[routerAddress] = newPair;

        emit NewRouterAdded(routerAddress, newPair);
    }
    function setDexPairStatus(address pair, bool status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.dexPairStatus[pair] = status;

        emit DexPairStatusChanged(pair, status);
    }
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.dexPairStatus[to] && ds.launchTime == 0) {
            ds.launchTime = block.timestamp;
        }

        if (ds.launchTime != 0) {
            uint256 timePassedSinceLaunch = block.timestamp - ds.launchTime;
            if (timePassedSinceLaunch > (28 * ds._day)) {
                ds.buyTaxPercentage = ds.sellTaxPercentage = 2;
            } else if (timePassedSinceLaunch >= (14 * ds._day)) {
                ds.buyTaxPercentage = 2;
                ds.sellTaxPercentage = 3;
            } else if (timePassedSinceLaunch >= (7 * ds._day)) {
                ds.buyTaxPercentage = 2;
                ds.sellTaxPercentage = 4;
            } else if (timePassedSinceLaunch >= ds._day) {
                ds.buyTaxPercentage = 3;
                ds.sellTaxPercentage = 5;
            } else {
                ds.buyTaxPercentage = 3;
                ds.sellTaxPercentage = 10;
            }
        }

        if (
            (ds.dexPairStatus[from] || ds.dexPairStatus[to]) &&
            !(ds.isExcludedFromTax[from] || ds.isExcludedFromTax[to]) &&
            !ds._inSwapAndLiquify
        ) {
            uint256 taxValue;
            if (ds.dexPairStatus[to] && ds.pairToRouter[to] != address(0)) {
                // sell
                uint256 contractBalance = balanceOf(address(this));
                uint256 tokenBalanceInPool;
                uint256 ethBalanceInPool;
                (tokenBalanceInPool, ethBalanceInPool, ) = IDexV2Pair(to)
                    .getReserves();
                uint256 tokenWorth = (contractBalance * ethBalanceInPool) /
                    tokenBalanceInPool;
                if (tokenWorth >= 50000000000000000) {
                    _swapTokensForEth(contractBalance, to);
                    payable(ds.developmentWallet).transfer(
                        address(this).balance
                    );
                }

                taxValue = (value * ds.sellTaxPercentage) / 100;
            } else {
                taxValue = (value * ds.buyTaxPercentage) / 100;
            }
            value -= taxValue;
            super._update(from, address(this), taxValue);
        }
        super._update(from, to, value);
    }
    function changeDevelopmentWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newWallet != address(0), "ERC20: new wallet is zero address");
        address oldWallet = ds.developmentWallet;
        ds.developmentWallet = newWallet;

        emit DevelopmentWalletChanged(oldWallet, newWallet);
    }
    function excludeFromTax(address account, bool status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromTax[account] = status;

        emit TaxExclusionUpdated(account, status);
    }
    function _swapTokensForEth(
        uint256 tokenAmount,
        address pair
    ) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IDexV2Router dexRouter = IDexV2Router(ds.pairToRouter[pair]);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            (block.timestamp + 300)
        );
    }
}
