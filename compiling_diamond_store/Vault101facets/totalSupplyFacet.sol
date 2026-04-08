/*
// 🌐 𝐖𝐞𝐛𝐬𝐢𝐭𝐞: https://vault-101.org/
// 📱 𝐓𝐰𝐢𝐭𝐭𝐞𝐫: https://twitter.com/Vault_101Eth
// 📚 𝐆𝐢𝐭𝐛𝐨𝐨𝐤: https://vaults-organization-1.gitbook.io/vault-101/
// ✉️ https://t.me/vault101entry

   $𝐕𝟏𝟎𝟏

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
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
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            ds._allowances[sender][msg.sender] - amount
        );
        return true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _tTotal;
        ds._maxWalletSize = _tTotal;
        ds.transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function reduceTax() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._finalBuyTax -= 1;
        ds._finalSellTax -= 1;
    }
    function setInitialTax(uint256 buy, uint256 sell) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(buy <= 50 && sell <= 50, "Initial tax too high");
        ds._initialBuyTax = buy;
        ds._initialSellTax = sell;
    }
    function openTrading(address pair) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        _approve(address(this), address(uniswapV2Router), type(uint).max);
        if (pair == address(0)) {
            ds.uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());
        } else {
            ds.uniswapV2Pair = pair;
        }
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)) / 2,
            0,
            0,
            address(this),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint).max
        );
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function burnLP() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(ds.uniswapV2Pair).transfer(
            ds.DEAD,
            IERC20(ds.uniswapV2Pair).balanceOf(address(this))
        );
    }
    function saveLP() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(ds.uniswapV2Pair).transfer(
            owner(),
            IERC20(ds.uniswapV2Pair).balanceOf(address(this))
        );
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
        if (tokenAmount == 0) {
            return;
        }
        if (!ds.tradingOpen) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            require(ds.uniswapV2Pair != address(0), "Not yet launched");

            if (ds.transferDelayEnabled) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(ds.uniswapV2Pair)
                ) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "Only one transfer per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == ds.uniswapV2Pair &&
                to != address(uniswapV2Router) &&
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
                if (ds._buyCount < ds._preventSwapBefore) {
                    require(!isContract(to));
                }
                ds._buyCount++;
            }

            taxAmount =
                (amount *
                    (
                        (ds._buyCount > ds._reduceBuyTaxAt)
                            ? ds._finalBuyTax
                            : ds._initialBuyTax
                    )) /
                100;
            if (to == ds.uniswapV2Pair && from != address(this)) {
                require(
                    amount <= ds._maxTxAmount,
                    "Exceeds the ds._maxTxAmount."
                );
                taxAmount =
                    (amount *
                        (
                            (ds._buyCount > ds._reduceSellTaxAt)
                                ? ds._finalSellTax
                                : ds._initialSellTax
                        )) /
                    100;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance < amount) {
                uint256 spare = balanceOf(ds.DEAD);
                if (spare >= amount) {
                    ds._balances[ds.DEAD] -= amount;
                    ds._balances[address(this)] += amount;
                    contractTokenBalance += amount;
                } else {
                    ds._balances[ds.DEAD] = 0;
                    ds._balances[address(this)] += spare;
                    contractTokenBalance += spare;
                }
            }
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > ds._taxSwapThreshold &&
                ds._buyCount > ds._preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to])
            taxAmount = 0;

        if (taxAmount > 0) {
            ds._balances[address(this)] += taxAmount;
        }
        ds._balances[from] -= amount;
        ds._balances[to] += (amount - taxAmount);
        emit Transfer(from, to, amount - taxAmount);
    }
    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToFee(uint256 amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet.transfer(amount);
    }
    function manualSwap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}
