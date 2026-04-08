/**

Telegram : https://t.me/MataMemecoin

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event MaxWalletPercUpdated(uint _maxWalletPerc);
    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balance[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[holder][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.tradingOpen, "Trading is not enabled yet");
        ds._maxTxAmount = _tTotal;
        ds.maxWallet = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
        emit MaxWalletPercUpdated(_tTotal);
        ds.transferDelayEnabled = false;
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        ds.uniswapV2Router.addLiquidityETH{value: address(this).ds.balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        ds._maxTxAmount = (_tTotal * 20) / 1000;
        ds.maxWallet = (_tTotal * 20) / 1000;
        ds.taxSellPerc = 45;
        ds.taxBuyPerc = 20;
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
        );
    }
    function Launch() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = true;
    }
    function lowerTaxes() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxSellPerc = 35;
        ds.taxBuyPerc = 10;
    }
    function dropTaxes() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxSellPerc = 3;
        ds.taxBuyPerc = 3;
    }
    function _approve(address holder, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(holder != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[holder][spender] = amount;
        emit Approval(holder, spender, amount);
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
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, "Balance less then transfer");

        uint256 taxAmount = 0;
        if (!(ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to])) {
            require(ds.tradingOpen, "Trading is not enabled yet");
            require(amount <= ds._maxTxAmount, "Amount exceed max trnx amount");

            if (ds.transferDelayEnabled) {
                if (
                    to != address(ds.uniswapV2Router) &&
                    to != address(ds.uniswapV2Pair)
                ) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (to != ds.uniswapV2Pair) {
                require(
                    balanceOf(to) + amount <= ds.maxWallet,
                    "max Wallet limit exceeded"
                );
            }

            uint256 contractETHBalance = address(this).ds.balance;
            if (contractETHBalance > 0) {
                sendETHToFee(address(this).ds.balance);
            }

            if (from == ds.uniswapV2Pair) {
                taxAmount = amount.mul(ds.taxBuyPerc).div(100);
            } else if (to == ds.uniswapV2Pair) {
                // Only Swap taxes on a sell
                taxAmount = amount.mul(ds.taxSellPerc).div(100);
                uint256 contractTokenBalance = balanceOf(address(this));
                if (!ds.inSwap) {
                    if (contractTokenBalance > _tTotal / 1000) {
                        // 0.01%
                        swapTokensForEth(contractTokenBalance);
                    }
                }
            }
        }
        _tokenTransfer(from, to, amount, taxAmount);
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.deployerWallet.transfer(amount);
    }
    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.deployerWallet,
            "Only team can call this function"
        );
        uint256 contractETHBalance = address(this).ds.balance;
        sendETHToFee(contractETHBalance);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        uint256 _taxAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 remainingAmount = amount - _taxAmount;
        ds.balance[sender] = ds.balance[sender].sub(amount);
        ds.balance[recipient] = ds.balance[recipient].add(remainingAmount);
        ds.balance[address(this)] = ds.balance[address(this)].add(_taxAmount);
        emit Transfer(sender, recipient, remainingAmount);
    }
    function manualswap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFee[msg.sender],
            "Only team can call this function"
        );
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    function transferERC20(IERC20 token, uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //function to transfer stuck erc20 tokens
        require(
            msg.sender == ds.deployerWallet,
            "Only team can call this function"
        );
        require(
            token != IERC20(address(this)),
            "You can't withdraw tokens from owned by contract."
        );
        uint256 erc20balance = token.balanceOf(address(this));
        require(amount <= erc20balance, "ds.balance is low");
        token.transfer(ds.deployerWallet, amount);
    }
}
