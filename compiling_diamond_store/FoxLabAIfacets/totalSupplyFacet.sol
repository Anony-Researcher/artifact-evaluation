/** 
 (               (                            (     
 )\ )            )\ )           )      (      )\ )  
(()/(         ) (()/(     )  ( /(      )\    (()/(  
 /(_)) (   ( /(  /(_)) ( /(  )\())  ((((_)(   /(_)) 
(_))_| )\  )\())(_))   )(_))((_)\    )\ _ )\ (_))   
| |_  ((_)((_)\ | |   ((_)_ | |(_)   (_)_\(_)|_ _|  
| __|/ _ \\ \ / | |__ / _` || '_ \ _  / _ \   | |   
|_|  \___//_\_\ |____|\__,_||_.__/(_)/_/ \_\ |___|  

Web: https://foxlabai.solutions

TG: https://t.me/FoxLabAi_Portal

Twitter (X): https://twitter.com/FoxLabAi

**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TradingActive(bool _tradingOpen, bool _swapEnabled);
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
        _transfer(msg.sender, recipient, amount);
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
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = allowance(sender, msg.sender);

        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _tTotal;
        ds._maxWalletSize = _tTotal;
        ds.transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function addLiquidity() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.addedLiquidity, "Liquidity already added");
        ds.uniswapV2Router = IUniswapV2Router02(uniswapRouterAddr);

        _approve(address(this), address(ds.uniswapV2Router), _tTotal);

        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            (balanceOf(address(this)) * _clog) / 100,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
        );
        ds.addedLiquidity = true;
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.addedLiquidity, "Liquidity must be added");
        require(!ds.tradingOpen, "Trading is already open");

        ds._initBlockTimestamp = block.timestamp;
        ds.swapEnabled = true;
        ds.tradingOpen = true;
        emit TradingActive(ds.tradingOpen, ds.swapEnabled);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!ds.tradingOpen) {
            require(
                ds._isExcludedFromFee[to] || ds._isExcludedFromFee[from],
                "trading not yet open"
            );
        }
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            taxAmount = getTax(amount);

            if (ds.transferDelayEnabled) {
                if (
                    to != address(ds.uniswapV2Router) &&
                    to != address(ds.uniswapV2Pair)
                ) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer:: Transfer Delay enabled. Only one purchase per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }
            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(
                    amount <= ds._maxTxAmount,
                    "Exceeds the ds._maxTxAmount."
                );
                require(
                    balanceOf(to) + amount <= ds._maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                ds._transferCount++;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                ds._transferCount > _preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;

                if (contractETHBalance > 5 * 10 ** 16) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (taxAmount > 0) {
            ds._balances[address(this)] =
                ds._balances[address(this)] +
                taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }

        ds._balances[from] = ds._balances[from] - amount;
        ds._balances[to] = ds._balances[to] + (amount - taxAmount);
        emit Transfer(from, to, amount - taxAmount);
    }
    function getTax(uint256 amount) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 sniperTime = 300;
        uint256 passedSeconds = block.timestamp - ds._initBlockTimestamp;

        if (passedSeconds < sniperTime) return (amount * _sniperTax) / 100;
        else return (amount * _fees) / 100;
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a > b ? b : a;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet.transfer(amount);
    }
    function LeavingsWithdraw() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._taxWallet);

        sendETHToFee(address(this).balance);
    }
}
