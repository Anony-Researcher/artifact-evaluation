/**

     ## ##   ### ##   ### ##    ## ##   
    ##   ##   ##  ##   ##  ##  ##   ##  
    ##   ##   ##  ##   ##  ##       ##  
    ##   ##   ## ##    ## ##      ###   
    ##   ##   ## ##    ##  ##       ##  
    ##   ##   ##  ##   ##  ##  ##   ##  
     ## ##   #### ##  ### ##    ## ##   

Telegram: https://link3.to/orb3pro
Twitter:  https://twitter.com/Orb3Tech
Website:  https://orb3.tech

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context {
    using Math for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event SwapTokensForETH(uint256 amountIn, address[] path);
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: Exceeds allowance"
            )
        );
        return true;
    }
    function setFee(
        uint _buyLp,
        uint _buyReward,
        uint _buyProject,
        uint _sellLp,
        uint _sellReward,
        uint _sellProject
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._buyliquidityFee = _buyLp;
        ds._buyrewardsFee = _buyReward;
        ds._buyprojectFee = _buyProject;

        ds._sellliquidityFee = _sellLp;
        ds._sellrewardsFee = _sellReward;
        ds._sellprojectFee = _sellProject;

        ds.buyFee = ds._buyliquidityFee.add(ds._buyrewardsFee).add(
            ds._buyprojectFee
        );
        ds.sellFee = ds._sellliquidityFee.add(ds._sellrewardsFee).add(
            ds._sellprojectFee
        );
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.LimitsActive = false;
        ds.maxWallet = ds._totalSupply;
        ds.maxTransaction = ds._totalSupply;
    }
    function openTrade() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.TradeActive, "Already Enabled!");
        ds.TradeActive = true;
    }
    function excludeFromFee(address _adr, bool _status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._excludedFromFee[_adr] = _status;
    }
    function setMaxWalletLimit(uint256 newLimit) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWallet = newLimit;
    }
    function setTxLimit(uint256 newLimit) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTransaction = newLimit;
    }
    function setMarketingWallet(address _newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWallet = _newWallet;
    }
    function setDeveloperWallet(address _newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.developerWallet = _newWallet;
    }
    function setRewardWallet(address _newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rewardWallet = _newWallet;
    }
    function setSwapSetting(
        bool _swapenabled,
        bool _protected
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = _swapenabled;
        ds.swapProtection = _protected;
    }
    function setSwapThreshold(uint _threshold) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapThreshold = _threshold;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (sender == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (recipient == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        if (amount == 0) {
            revert ERC20ZeroTransfer();
        }

        if (ds.inSwap) {
            return normalTransfer(sender, recipient, amount);
        } else {
            if (
                !ds._excludedFromFee[sender] &&
                !ds._excludedFromFee[recipient] &&
                ds.LimitsActive
            ) {
                require(ds.TradeActive, "Trade Not Active!");
                require(amount <= ds.maxTransaction, "Exceeds maxTxAmount");
                if (!ds._pairAddress[recipient]) {
                    require(
                        balanceOf(recipient).add(amount) <= ds.maxWallet,
                        "Exceeds ds.maxWallet"
                    );
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >=
                ds.swapThreshold;

            if (
                overMinimumTokenBalance &&
                !ds.inSwap &&
                !ds._pairAddress[sender] &&
                ds.swapEnabled &&
                !ds._excludedFromFee[sender] &&
                !ds._excludedFromFee[recipient]
            ) {
                swapBack(contractTokenBalance);
            }

            ds._balances[sender] = ds._balances[sender].sub(
                amount,
                "Insufficient Balance"
            );

            uint256 ToBeReceived = FeeCheckPoint(sender, recipient)
                ? amount
                : FeeCalculation(sender, recipient, amount);

            ds._balances[recipient] = ds._balances[recipient].add(ToBeReceived);

            emit Transfer(sender, recipient, ToBeReceived);
            return true;
        }
    }
    function normalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        ds._balances[recipient] = ds._balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function swapBack(uint contractBalance) internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.swapProtection) contractBalance = ds.swapThreshold;

        uint256 totalShares = ds.buyFee.add(ds.sellFee);
        uint256 _liquidityShare = ds._buyliquidityFee.add(ds._sellliquidityFee);
        uint256 _ProjectShare = ds._buyprojectFee.add(ds._sellprojectFee);
        // uint256 _rewardShare  = ds._buyrewardsFee.add(ds._sellrewardsFee);

        uint256 tokensForLP = contractBalance
            .mul(_liquidityShare)
            .div(totalShares)
            .div(2);
        uint256 tokensForSwap = contractBalance.sub(tokensForLP);

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance.sub(initialBalance);

        uint256 totalETHFee = totalShares.sub(_liquidityShare.div(2));

        uint256 amountETHLiquidity = amountReceived
            .mul(_liquidityShare)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHMarketing = amountReceived.mul(_ProjectShare).div(
            totalETHFee
        );
        uint256 amountETHReward = amountReceived.sub(amountETHLiquidity).sub(
            amountETHMarketing
        );

        if (amountETHMarketing > 0)
            transferToAddressETH(ds.marketingWallet, amountETHMarketing);

        if (amountETHReward > 0)
            transferToAddressETH(ds.developerWallet, amountETHReward);

        if (amountETHLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountETHLiquidity);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.dexRouter.WETH();

        _approve(address(this), address(ds.dexRouter), tokenAmount);

        // make the swap
        ds.dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.dexRouter), tokenAmount);

        // add the liquidity
        ds.dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            ds.marketingWallet,
            block.timestamp
        );
    }
    function transferToAddressETH(address recipient, uint256 amount) private {
        payable(recipient).transfer(amount);
    }
    function FeeCheckPoint(
        address sender,
        address recipient
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._excludedFromFee[sender] || ds._excludedFromFee[recipient]) {
            return true;
        } else if (ds._pairAddress[sender] || ds._pairAddress[recipient]) {
            return false;
        } else {
            return false;
        }
    }
    function FeeCalculation(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint feeAmount;

        unchecked {
            if (ds._pairAddress[sender]) {
                feeAmount = amount.mul(ds.buyFee).div(ds.feeDenominator);
            } else if (ds._pairAddress[recipient]) {
                feeAmount = amount.mul(ds.sellFee).div(ds.feeDenominator);
            }

            if (feeAmount > 0) {
                ds._balances[address(this)] = ds._balances[address(this)].add(
                    feeAmount
                );
                emit Transfer(sender, address(this), feeAmount);
            }

            return amount.sub(feeAmount);
        }
    }
    function rescueTokens(address _token, uint _amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.developerWallet, "Unauthorized");
        (bool success, ) = address(_token).call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                ds.developerWallet,
                _amount
            )
        );
        require(success, "Token payment failed");
    }
}
