// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract enableTradingFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "ERROR: Trading already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
        ds.lastSwap = block.number;
    }
    function changeTax(
        uint256 _newBuyFee,
        uint256 _newSellFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._finalBuyTax = _newBuyFee;
        ds._finalSellTax = _newSellFee;
    }
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
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
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _tTotal;
        ds._maxWalletSize = _tTotal;
        ds._taxSwapThreshold = 2000000 * 10 ** _decimals;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(ds.tradingOpen, "Trading not open");
                require(
                    amount <= ds._maxTxAmount,
                    "Exceeds the ds._maxTxAmount."
                );
                require(
                    balanceOf(to) + amount <= ds._maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                taxAmount = amount.mul(ds._finalBuyTax).div(100);
            }

            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul(ds._finalSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > ds._taxSwapThreshold &&
                ds.lastSwap != block.number
            ) {
                swapTokensForEth(ds._taxSwapThreshold);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                ds.lastSwap = block.number;
            }
        }

        if (taxAmount > 0) {
            ds._balances[address(this)] = ds._balances[address(this)].add(
                taxAmount
            );
            emit Transfer(from, address(this), taxAmount);
        }

        ds._balances[from] = ds._balances[from].sub(amount);
        ds._balances[to] = ds._balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
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
    function manualSwap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 taxAmount = (amount.div(2));
        uint256 devAmount = (amount - taxAmount);
        ds._taxWallet.transfer(taxAmount);
        ds._devWallet.transfer(devAmount);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function rescueERC20Token(address _tokenAddr, uint _amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_tokenAddr != address(this));
        IERC20(_tokenAddr).transfer(ds._devWallet, _amount);
    }
    function manualSend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            ds._devWallet.transfer(ethBalance);
        }
    }
}
