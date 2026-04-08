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
    event EarthFundWalletChanged(
        address indexed oldWallet,
        address indexed newWallet
    );
    event OperationsWalletChanged(
        address indexed oldWallet,
        address indexed newWallet
    );
    event TaxExclusionUpdated(address indexed account, bool indexed status);
    event MaxBuySellLimitExclusionUpdated(
        address indexed account,
        bool indexed status
    );
    event MaxWalletLimitExclusionUpdated(
        address indexed account,
        bool indexed status
    );
    function addNewDexRouter(address routerAddress) external onlyOwner {
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
        ds.isExcludedFromMaxWalletLimit[newPair] = true;

        emit NewRouterAdded(routerAddress, newPair);
    }
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            (ds.dexPairStatus[from] || ds.dexPairStatus[to]) &&
            !(ds.isExcludedFromTax[from] || ds.isExcludedFromTax[to]) &&
            !ds._inSwapAndLiquify
        ) {
            uint256 taxValue = (value *
                (ds._earthFundTax + ds._operationsTax)) / 1000;
            value -= taxValue;

            if (ds.dexPairStatus[to]) {
                // sell
                _transferETH(to);
                require(
                    (ds.isExcludedFromMaxBuySellLimit[from] ||
                        value <= ds.maxBuySellLimit),
                    "ERC20: ds.maxBuySellLimit exceeded"
                );
            } else {
                // buy
                require(
                    (ds.isExcludedFromMaxBuySellLimit[to] ||
                        value <= ds.maxBuySellLimit),
                    "ERC20: ds.maxBuySellLimit exceeded"
                );
            }

            super._update(from, address(this), taxValue);
        }
        require(
            (ds.isExcludedFromMaxWalletLimit[to] ||
                (value + balanceOf(to)) <= ds.maxWalletLimit),
            "ERC20: ds.maxWalletLimit exceeded"
        );
        super._update(from, to, value);
    }
    function changeEarthFundWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newWallet != address(0), "ERC20: new wallet is zero address");
        address oldWallet = ds.earthFundWallet;
        ds.earthFundWallet = newWallet;

        emit EarthFundWalletChanged(oldWallet, newWallet);
    }
    function changeOperationsWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newWallet != address(0), "ERC20: new wallet is zero address");
        address oldWallet = ds.operationsWallet;
        ds.operationsWallet = newWallet;

        emit OperationsWalletChanged(oldWallet, newWallet);
    }
    function excludeFromTax(address account, bool status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromTax[account] = status;

        emit TaxExclusionUpdated(account, status);
    }
    function excludeFromMaxBuySellLimit(
        address account,
        bool status
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromMaxBuySellLimit[account] = status;

        emit MaxBuySellLimitExclusionUpdated(account, status);
    }
    function excludeFromMaxWalletLimit(
        address account,
        bool status
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromMaxWalletLimit[account] = status;

        emit MaxWalletLimitExclusionUpdated(account, status);
    }
    function _transferETH(address to) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= 1000000000000000) {
            _swapTokensForEth(contractBalance, to);
            payable(ds.earthFundWallet).transfer(
                (address(this).balance * ds._earthFundTax) / 20
            );
            payable(ds.operationsWallet).transfer(address(this).balance);
        }
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
