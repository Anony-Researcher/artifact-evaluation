// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "./TestLib.sol";
contract updateSwapAndLiquifiyFacet is ERC20, Manageable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier nonReentrant() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // On the first call to nonReentrant, _notEntered will be true
        require(ds._status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        ds._status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        ds._status = _NOT_ENTERED;
    }

    event UpdateSwapAndLiquify(bool value);
    event SetMarketingFee(uint256 onBuy, uint256 onSell);
    event SetLiquidityFee(uint256 onBuy, uint256 onSell);
    event SetBurnFee(uint256 onBuy, uint256 onSell);
    event SetDistribution(uint256 liquidity, uint256 marketing);
    event UpdateSphynxSwapRouter(
        address indexed newAddress,
        address indexed oldAddress
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event GetFee(address indexed account, bool isGetFee);
    event SetNativeAmountToSwap(uint256 nativeAmountToSwap);
    event MarketingWalletUpdated(
        address indexed newMarketingWallet,
        address indexed oldMarketingWallet
    );
    event UpdateMaxTxAmount(uint256 txAmount);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function updateSwapAndLiquifiy(bool value) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.SwapAndLiquifyEnabled = value;
        emit UpdateSwapAndLiquify(value);
    }
    function updateLiquidityWallet(
        address _liquidityWallet
    ) external onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityWallet = _liquidityWallet;
    }
    function updateTrueBurn(bool _value) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.trueBurn = _value;
    }
    function setMarketingFee(
        uint256 _onBuy,
        uint256 _onSell
    ) external onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_onBuy <= 10 && _onSell <= 10, "SPHYNX: Invalid marketingFee");
        ds.marketingFeeOnBuy = _onBuy;
        ds.marketingFeeOnSell = _onSell;
        ds.totalFeesOnBuy = ds.marketingFeeOnBuy.add(ds.liquidityFeeOnBuy);
        ds.totalFeesOnSell = ds.marketingFeeOnSell.add(ds.liquidityFeeOnSell);
        emit SetMarketingFee(_onBuy, _onSell);
    }
    function setLiquidityFee(
        uint256 _onBuy,
        uint256 _onSell
    ) external onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_onBuy <= 10 && _onSell <= 10, "SPHYNX: Invalid marketingFee");
        ds.liquidityFeeOnBuy = _onBuy;
        ds.liquidityFeeOnSell = _onSell;
        ds.totalFeesOnBuy = ds.liquidityFeeOnBuy.add(ds.marketingFeeOnBuy);
        ds.totalFeesOnSell = ds.liquidityFeeOnSell.add(ds.marketingFeeOnSell);
        emit SetLiquidityFee(_onBuy, _onSell);
    }
    function setBurnFee(uint256 _onBuy, uint256 _onSell) external onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_onBuy <= 10, "SPHYNX: Invalid burnFee");
        require(_onSell <= 10, "SPHYNX: Invalid burnFee");
        ds.burnFeeOnBuy = _onBuy;
        ds.burnFeeOnSell = _onSell;
        emit SetBurnFee(_onBuy, _onSell);
    }
    function updateShares(
        uint256 _liquidity,
        uint256 _marketing
    ) external onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityShare = _liquidity;
        ds.marketingShare = _marketing;
        ds.totalShares = ds.liquidityShare.add(ds.marketingShare);

        emit SetDistribution(_liquidity, _marketing);
    }
    function updateSphynxSwapRouter(address newAddress) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAddress != address(ds.sphynxSwapRouter),
            "SPHYNX: The router already has that address"
        );
        emit UpdateSphynxSwapRouter(newAddress, address(ds.sphynxSwapRouter));
        ds.sphynxSwapRouter = ISphynxRouter02(newAddress);
        address _sphynxSwapPair;
        _sphynxSwapPair = ISphynxFactory(ds.sphynxSwapRouter.factory()).getPair(
            address(this),
            ds.sphynxSwapRouter.WETH()
        );
        if (_sphynxSwapPair == address(0)) {
            _sphynxSwapPair = ISphynxFactory(ds.sphynxSwapRouter.factory())
                .createPair(address(this), ds.sphynxSwapRouter.WETH());
        }
        _setAutomatedMarketMakerPair(ds.sphynxSwapPair, false);
        ds.sphynxSwapPair = _sphynxSwapPair;
        _setAutomatedMarketMakerPair(ds.sphynxSwapPair, true);
    }
    function excludeFromFees(
        address account,
        bool excluded
    ) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFees[account] != excluded,
            "SPHYNX: Account is already the value of 'excluded'"
        );
        ds._isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    function setFeeAccount(address account, bool isGetFee) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isGetFees[account] != isGetFee,
            "SPHYNX: Account is already the value of 'isGetFee'"
        );
        ds._isGetFees[account] = isGetFee;

        emit GetFee(account, isGetFee);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyManager {
        _setAutomatedMarketMakerPair(pair, value);
    }
    function setNativeAmountToSwap(uint256 _nativeAmount) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.nativeAmountToSwap = _nativeAmount;
        emit SetNativeAmountToSwap(ds.nativeAmountToSwap);
    }
    function updateMarketingWallet(
        address newMarketingWallet
    ) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newMarketingWallet != ds.marketingWallet,
            "SPHYNX: The marketing wallet is already this address"
        );
        excludeFromFees(newMarketingWallet, true);
        excludeFromFees(ds.marketingWallet, false);
        emit MarketingWalletUpdated(newMarketingWallet, ds.marketingWallet);
        ds.marketingWallet = payable(newMarketingWallet);
    }
    function updateMaxTxAmount(uint256 _amount) public onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTxAmount = _amount;
        emit UpdateMaxTxAmount(_amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount <= ds.maxTxAmount, "max-tx-amount-overflow");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (ds.SwapAndLiquifyEnabled) {
            uint256 contractTokenBalance = balanceOf(address(this)).sub(
                ds.burnContractBalance
            );
            uint256 nativeTokenAmount = _getTokenAmountFromNative();

            bool canSwap = contractTokenBalance >= nativeTokenAmount;

            if (
                canSwap && !ds.swapping && !ds.automatedMarketMakerPairs[from]
            ) {
                ds.swapping = true;
                // Set number of tokens to sell to nativeTokenAmount
                contractTokenBalance = nativeTokenAmount;
                swapTokens(contractTokenBalance);
                ds.swapping = false;
            }
        }

        if (ds._isGetFees[to] && ds.blockNumber == 0) {
            ds.blockNumber = block.number;
        }

        // indicates if fee should be deducted from transfer
        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            if (block.number - ds.blockNumber <= 10) {
                uint256 afterBalance = balanceOf(to) + amount;
                require(
                    afterBalance <= 250000 * (10 ** 18),
                    "Owned amount exceeds the maxOwnedAmount"
                );
            }
            uint256 fees;
            if (ds._isGetFees[from] || ds._isGetFees[to]) {
                if (block.number - ds.blockNumber <= 10) {
                    fees = amount.mul(99).div(10 ** 2);
                } else {
                    uint256 burnFee;
                    if (ds._isGetFees[from]) {
                        fees = amount.mul(ds.totalFeesOnBuy).div(10 ** 2);
                        burnFee = ds.burnFeeOnBuy;
                    } else {
                        fees = amount.mul(ds.totalFeesOnSell).div(10 ** 2);
                        burnFee = ds.burnFeeOnSell;
                    }
                    uint256 burnAmount = amount.mul(burnFee).div(10 ** 2);
                    amount = amount.sub(burnAmount);
                    super._transfer(from, address(this), burnAmount);
                    if (ds.trueBurn) {
                        _burn(address(this), burnAmount);
                    } else {
                        ds.burnContractBalance = ds.burnContractBalance.add(
                            burnAmount
                        );
                    }
                }
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);
            }
        }

        super._transfer(from, to, amount);
    }
    function withdrawFromBurn(uint256 _amount) external onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.burnContractBalance = ds.burnContractBalance.sub(_amount);
        super._transfer(address(this), msg.sender, _amount);
    }
    function withdrawNative() external payable onlyManager {
        address payable msgSender = payable(msg.sender);
        msgSender.transfer(address(this).balance);
    }
    function withdrawToken(
        address _token,
        uint256 _amount
    ) external onlyManager {
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }
    function _getTokenAmountFromNative() internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokenAmount;
        address[] memory path = new address[](2);
        path[0] = ds.sphynxSwapRouter.WETH();
        path[1] = address(this);
        uint256[] memory amounts = ds.sphynxSwapRouter.getAmountsOut(
            ds.nativeAmountToSwap,
            path
        );
        tokenAmount = amounts[1];
        return tokenAmount;
    }
    function swapTokens(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensForLiquidity = tokenAmount.mul(ds.liquidityShare).div(
            ds.totalShares
        );
        uint256 swapTokenAmount = tokenAmount.sub(tokensForLiquidity);
        swapTokensForNative(swapTokenAmount);
        uint256 swappedNative = address(this).balance;
        uint256 nativeForLiquidity = swappedNative.mul(ds.liquidityShare).div(
            ds.totalShares
        );
        uint256 nativeForMarketing = swappedNative.sub(nativeForLiquidity);
        if (tokensForLiquidity > 0) {
            addLiquidity(tokensForLiquidity, nativeForLiquidity);
        }
        if (nativeForMarketing > 0) {
            transferNativeToMarketingWallet(nativeForMarketing);
        }
    }
    function swapTokensForNative(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the sphynxswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.sphynxSwapRouter.WETH();

        _approve(address(this), address(ds.sphynxSwapRouter), tokenAmount);

        // make the swap
        ds.sphynxSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of Native
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 nativeAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.sphynxSwapRouter), tokenAmount);

        // add the liquidity
        ds.sphynxSwapRouter.addLiquidityETH{value: nativeAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            ds.liquidityWallet,
            block.timestamp
        );
    }
    function transferNativeToMarketingWallet(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWallet.transfer(amount);
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.automatedMarketMakerPairs[pair] != value,
            "SPHYNX: Automated market maker pair is already set to that value"
        );
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
