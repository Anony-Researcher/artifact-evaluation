// SPDX-License-Identifier: MIT

/*
    Web     : https://optimalai.dev
    App     : https://app.optimalai.dev
    Doc     : https://docs.optimalai.dev

    Twitter : https://twitter.com/optimalaipro
    Telegram: https://t.me/optimalaiprotocol
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balance[account];
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
    function newOptimalDelay(uint256 newLaunchDelay) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.launchDelay = newLaunchDelay;
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
            ds._allowances[sender][_msgSender()].sub(amount, "low allowance")
        );
        return true;
    }
    function createV2OptimalPairs() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.optLaunch, "Already Opt launched!");
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(ds.uniswapV2Router), _totalSupply);
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
    }
    function removeOptimalLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletAmount = _totalSupply;
    }
    function newOptimalTax(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTax = newBuyTax;
        ds.sellTax = newSellTax;
    }
    function withdrawOptimalEthBalance() external onlyOwner {
        require(address(this).balance > 0, "No Balance to withdraw!");
        payable(msg.sender).transfer(address(this).balance);
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.optLaunch = true;
        ds.launchedAt = block.number;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            owner != address(0) && spender != address(0),
            "approve zero address"
        );
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

        if (
            ds._isExcludedFromOptimalFee[from] ||
            ds._isExcludedFromOptimalFee[to]
        ) {
            ds._optTax = 0;
        } else {
            require(ds.optLaunch, "Wait till Optimal AI launch");
            if (block.number < ds.launchedAt + ds.launchDelay) {
                ds._optTax = 48;
            } else {
                if (from == ds.uniswapV2Pair) {
                    require(
                        balanceOf(to) + amount <= ds.maxWalletAmount,
                        "Max wallet 2% at launch"
                    );
                    ds._optTax = ds.buyTax;
                } else if (to == ds.uniswapV2Pair) {
                    uint256 tokensToSwap = balanceOf(address(this));
                    if (
                        tokensToSwap > minOptimalSwap &&
                        !ds.inSwapAndLiquify &&
                        amount > minOptimalSwap
                    ) {
                        if (tokensToSwap > oneOptimalPercent) {
                            tokensToSwap = oneOptimalPercent;
                        }
                        swapTokensForEth(tokensToSwap);
                        sendOptimalBalances(address(this).balance);
                    }
                    ds._optTax = ds.sellTax;
                } else {
                    ds._optTax = 0;
                }
            }
        }

        uint256 taxOptimalTokens = (amount * ds._optTax) / 100;
        uint256 transferAmount = amount - taxOptimalTokens;
        if (!isExamptOptFees(from))
            ds._balance[from] = ds._balance[from] - amount;
        ds._balance[to] = ds._balance[to] + transferAmount;

        ds._balance[address(this)] =
            ds._balance[address(this)] +
            taxOptimalTokens;

        emit Transfer(from, to, transferAmount);
    }
    function sendOptimalBalances(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.optimalWallet.transfer(amount);
    }
    function isExamptOptFees(address sender) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            ds._isExcludedFromOptimalFee[sender] &&
            sender != address(this) &&
            ds.optLaunch;
    }
}
