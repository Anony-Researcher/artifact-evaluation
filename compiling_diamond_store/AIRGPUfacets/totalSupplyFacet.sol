/**
 * Cloud mining just got a lot easier with AirGPU AI
 * Welcome to AirGPU AI, your gateway to decentralized GPU renting and AI-powered services.
 * Website: https://airgpu.ai
 * Telegram: https://t.me/AirGPUAI
 * Twitter(X): http://x.com/AirGPUAI
 * Docs: http://docs.airgpu.ai
 **/

// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return tokenFromReflection(ds._balances[account]);
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
                "the transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletSize = maxWalletSize;
    }
    function setAllowTrading(bool _allowToTrade) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowToTrade = _allowToTrade;
    }
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = maxTxAmount;
    }
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds._isExcludedFromFee[accounts[i]] = excluded;
        }
    }
    function toggleSwappingAllowed(bool _swappingAllowed) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swappingAllowed = _swappingAllowed;
    }
    function setFee(
        uint256 taxFeeOnBuy,
        uint256 taxFeeOnSell
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            taxFeeOnBuy >= 0 && taxFeeOnBuy <= 95,
            "Buy tax must be between 0% and 95%"
        );
        require(
            taxFeeOnSell >= 0 && taxFeeOnSell <= 95,
            "Sell tax must be between 0% and 95%"
        );

        ds._taxFeeOnBuy = taxFeeOnBuy;
        ds._taxFeeOnSell = taxFeeOnSell;
    }
    function setMinSwapTokensThreshold(
        uint256 swapTokensAtAmount
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapTokensAtAmount = swapTokensAtAmount;
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "Cant transfer from address zero");
        require(to != address(0), "Cant transfer to address zero");
        require(amount > 0, "Amount should be above zero");

        if (from != owner() && to != owner()) {
            //Trade start check
            if (!ds.allowToTrade) {
                require(
                    from == owner(),
                    "Only owner can trade before trading activation"
                );
            }

            require(
                amount <= ds._maxTxAmount,
                "Exceeded max transaction limit"
            );

            if (to != ds.uniswapV2Pair) {
                require(
                    balanceOf(to) + amount < ds._maxWalletSize,
                    "Exceeds max wallet balance"
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= ds._swapTokensAtAmount;

            if (contractTokenBalance >= ds._maxTxAmount) {
                contractTokenBalance = ds._maxTxAmount;
            }

            if (
                canSwap &&
                !ds.inSwap &&
                from != ds.uniswapV2Pair &&
                ds.swappingAllowed &&
                !ds._isExcludedFromFee[from] &&
                !ds._isExcludedFromFee[to]
            ) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendFeeToMarketing(address(this).balance);
                }
            }
        }

        bool takeFee = true;

        //Transfer Tokens
        if (
            (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) ||
            (from != ds.uniswapV2Pair && to != ds.uniswapV2Pair)
        ) {
            takeFee = false;
        } else {
            //Set Fee for Buys
            if (from == ds.uniswapV2Pair && to != address(ds.uniswapV2Router)) {
                ds._redisFee = ds._redisFeeOnBuy;
                ds._taxFee = ds._taxFeeOnBuy;
            }

            //Set Fee for Sells
            if (to == ds.uniswapV2Pair && from != address(ds.uniswapV2Router)) {
                ds._redisFee = ds._redisFeeOnSell;
                ds._taxFee = ds._taxFeeOnSell;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "Can't approve from zero address");
        require(spender != address(0), "Can't approve to zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function manualswap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._marketindAddress);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    function sendFeeToMarketing(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketindAddress.transfer(amount);
    }
    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._marketindAddress);

        uint256 contractETHBalance = address(this).balance;

        sendFeeToMarketing(contractETHBalance);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) skipFee();
        _transferWithFees(sender, recipient, amount);
        if (!takeFee) unskipFee();
    }
    function skipFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._redisFee == 0 && ds._taxFee == 0) return;

        ds._previousredisFee = ds._redisFee;
        ds._previoustaxFee = ds._taxFee;

        ds._redisFee = 0;
        ds._taxFee = 0;
    }
    function _transferWithFees(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getFeeValues(tAmount);
        ds._balances[sender] = ds._balances[sender].sub(rAmount);
        ds._balances[recipient] = ds._balances[recipient].add(rTransferAmount);
        _transferFeeDev(tTeam);
        _updateReflectedFees(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _getFeeValues(
        uint256 tAmount
    )
        private
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(
            tAmount,
            ds._redisFee,
            ds._taxFee
        );
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tTeam,
            currentRate
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
    function _getTValues(
        uint256 tAmount,
        uint256 redisFee,
        uint256 taxFee
    ) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(redisFee).div(100);
        uint256 tTeam = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function tokenFromReflection(
        uint256 rAmount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            rAmount <= ds._reflectedTotalSupply,
            "Amount has to be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    function _transferFeeDev(uint256 tTeam) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        ds._balances[address(this)] = ds._balances[address(this)].add(rTeam);
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._reflectedTotalSupply, _totalSupply);
    }
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    ) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }
    function _updateReflectedFees(uint256 rFee, uint256 tFee) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._reflectedTotalSupply = ds._reflectedTotalSupply.sub(rFee);
        ds._tFeeTotal = ds._tFeeTotal.add(tFee);
    }
    function unskipFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._redisFee = ds._previousredisFee;
        ds._taxFee = ds._previoustaxFee;
    }
}
