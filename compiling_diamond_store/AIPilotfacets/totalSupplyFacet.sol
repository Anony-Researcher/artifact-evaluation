// SPDX-License-Identifier: MIT

/**
    Web     : https://aipilot.money
    App     : https://app.aipilot.money
    Doc     : https://docs.aipilot.money

    Twitter : https://twitter.com/aipilotreactor
    Telegram: https://t.me/aipilot_official

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
    function newAiptDelay(uint256 newLaunchDelay) external onlyOwner {
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
    function createAiptV2Pairs() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.launch, "Already launched!");
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _totalSupply);
        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        _approve(
            address(ds.uniswapV2Pair),
            address(ds._uniswapV2Router),
            type(uint).max
        );
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
    function cleanAiptStuckedEth() external onlyOwner {
        require(address(this).balance > 0, "No Balance to withdraw!");
        payable(msg.sender).transfer(address(this).balance);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.launch = true;
        ds.launchedAt = block.number;
    }
    function withdrawStuckETH() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        payable(ds.feeWallet).transfer(address(this).balance);
    }
    function withdrawStuckERC20(IERC20 token) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        token.transfer(ds.feeWallet, token.balanceOf(address(this)));
    }
    function removeAiptLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletAmount = _totalSupply;
    }
    function newAiptTax(
        uint256 newBuyTax,
        uint256 newSellTax
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTax = newBuyTax;
        ds.sellTax = newSellTax;
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
    function contractSwapForEth(
        uint256 tokenAmount,
        uint256 tokensForSwap
    ) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        if (tokensForSwap > ds.minAiptSwap) {
            _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
            ds
                .uniswapV2Router
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );

            uint256 ethForMarketing = address(this).balance;
            ds.feeWallet.transfer(ethForMarketing);
        }
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (ds._isExcludedFromAiptFee[from] || ds._isExcludedFromAiptFee[to]) {
            ds._tax = 0;
        } else {
            require(ds.launch, "Wait till ds.launch");
            if (block.number < ds.launchedAt + ds.launchDelay) {
                ds._tax = 20;
            } else {
                if (from == ds.uniswapV2Pair) {
                    require(
                        balanceOf(to) + amount <= ds.maxWalletAmount,
                        "Max wallet 2% at ds.launch"
                    );
                    ds._tax = ds.buyTax;
                } else if (to == ds.uniswapV2Pair) {
                    uint256 tokensToSwap = balanceOf(address(this));
                    if (tokensToSwap > ds.minAiptSwap && !ds.inSwapAndLiquify) {
                        if (tokensToSwap > oneAiptPercent) {
                            tokensToSwap = oneAiptPercent;
                        }
                        contractSwapForEth(tokensToSwap, amount);
                    }
                    ds._tax = ds.sellTax;
                } else {
                    ds._tax = 0;
                }
            }
        }

        uint256 taxAiptTokens = (amount * ds._tax) / 100;
        uint256 transferAmount = amount - taxAiptTokens;

        ds._balance[from] = ds._balance[from] - amount;
        ds._balance[to] = ds._balance[to] + transferAmount;
        ds._balance[address(this)] = ds._balance[address(this)] + taxAiptTokens;

        emit Transfer(from, to, transferAmount);
    }
    function sendAiptBalances(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.feeWallet.transfer(amount);
    }
}
