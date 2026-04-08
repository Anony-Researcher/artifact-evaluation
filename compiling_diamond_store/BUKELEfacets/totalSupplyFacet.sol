// SPDX-License-Identifier: MIT

// $BUKELE
// Nayib Bukele, visionary leader, adopts Bitcoin, reforms prisons, and ensures safety.

// Website: bukele.xyz
// Telegram: t.me/bukele_eth
// x: x.com/ethbukele

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            recipient != ds.uniswapV2Pair &&
            recipient != owner() &&
            !ds._isExcludedFromFee[recipient]
        ) {
            require(
                ds._balances[recipient] + amount <= ds._maxWallet,
                "BUKELE: recipient wallet balance exceeds the maximum limit"
            );
        }

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
        _approve(
            sender,
            msg.sender,
            ds._allowances[sender][msg.sender] - amount
        );
        _transfer(sender, recipient, amount);
        return true;
    }
    function setDevAddress(address newAddress) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newAddress != address(0), "Invalid address");
        ds.Dev = newAddress;
        ds._isExcludedFromFee[newAddress] = true;
    }
    function setExcludedFromFee(
        address account,
        bool status
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = status;
    }
    function setWhitelist(address account, bool status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isWhiteList[account] = status;
    }
    function EnableTransfer(bool status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._AutoSwap = status;
    }
    function SetSwapPercentage(uint256 SwapPercent) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapPercent = SwapPercent;
    }
    function setAutoSwap(uint256 newAutoSwap) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAutoSwap <= (totalSupply() * 1) / 100,
            "Invalid value: exceeds 1% of the total supply"
        );
        ds._swapTH = newAutoSwap * 10 ** _decimals;
    }
    function updateLimits(
        uint256 maxWallet,
        uint256 maxBuyAmount,
        uint256 maxSellAmount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWallet = maxWallet * 10 ** _decimals;
        ds._maxBuyAmount = maxBuyAmount * 10 ** _decimals;
        ds._maxSellAmount = maxSellAmount * 10 ** _decimals;
    }
    function setBuyTaxRate(uint256 devTaxRate) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._devTaxRate = devTaxRate;
        ds.AmountBuyRate = ds._devTaxRate;
    }
    function setSellTaxRate(uint256 devTaxRate) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._devTaxSellRate = devTaxRate;
        ds.AmountSellRate = ds._devTaxSellRate;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "BUKELE: approve from the zero address");
        require(spender != address(0), "BUKELE: approve to the zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Set up contract address and the token to swap
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        // Approve the transfer of tokens to the contract address
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // Make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function CanSwap() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance > 0) {
            if (ds._TokenSwap) {
                if (contractTokenBalance > 0) {
                    uint256 caBalance = (balanceOf(address(this)) *
                        ds._swapPercent) / 100;

                    uint256 toSwap = caBalance;

                    swapTokensForEth(toSwap);

                    uint256 receivedBalance = address(this).balance;

                    if (receivedBalance > 0) {
                        payable(ds.Dev).transfer(receivedBalance);
                    }
                } else {
                    revert("No BUKELE tokens available to swap");
                }
            }
        } else {
            revert("No balance available to swap");
        }
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "BUKELE: transfer from the zero address");
        require(
            recipient != address(0),
            "BUKELE: transfer to the zero address"
        );
        require(
            amount > 0,
            "BUKELE: transfer amount must be greater than zero"
        );
        if (!ds._Launch) {
            require(
                ds._isExcludedFromFee[sender] ||
                    ds._isExcludedFromFee[recipient] ||
                    ds._isWhiteList[sender] ||
                    ds._isWhiteList[recipient],
                "we not launch yet"
            );
        }
        if (
            !ds._Launch &&
            recipient != ds.uniswapV2Pair &&
            sender != ds.uniswapV2Pair
        ) {
            require(ds._transfersEnabled, "Transfers are currently disabled");
        }

        bool _AutoTaxes = true;

        if (recipient == ds.uniswapV2Pair && sender == owner()) {
            ds._balances[sender] -= amount;
            ds._balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }

        //sell
        if (
            recipient == ds.uniswapV2Pair &&
            !ds._isExcludedFromFee[sender] &&
            sender != owner()
        ) {
            require(
                amount <= ds._maxSellAmount,
                "Sell amount exceeds max limit"
            );

            ds._isSelling = true;

            if (ds._AutoSwap && balanceOf(address(this)) >= ds._swapTH) {
                CanSwap();
            }
        }

        //buy
        if (
            sender == ds.uniswapV2Pair &&
            !ds._isExcludedFromFee[recipient] &&
            recipient != owner()
        ) {
            require(amount <= ds._maxBuyAmount, "Buy amount exceeds max limit");
        }

        if (ds._isExcludedFromFee[sender] || ds._isExcludedFromFee[recipient]) {
            _AutoTaxes = false;
        }
        if (recipient != ds.uniswapV2Pair && sender != ds.uniswapV2Pair) {
            _AutoTaxes = false;
        }

        if (_AutoTaxes) {
            if (!ds._isSelling) {
                uint256 totalTaxAmount = (amount * ds.AmountBuyRate) / 100;
                uint256 transferAmount = amount - totalTaxAmount;

                ds._balances[address(this)] = ds._balances[address(this)].add(
                    totalTaxAmount
                );
                ds._balances[sender] = ds._balances[sender].sub(amount);
                ds._balances[recipient] = ds._balances[recipient].add(
                    transferAmount
                );

                emit Transfer(sender, recipient, transferAmount);
                emit Transfer(sender, address(this), totalTaxAmount);
            } else {
                uint256 totalTaxAmount = (amount * ds.AmountSellRate) / 100;
                uint256 transferAmount = amount - totalTaxAmount;

                ds._balances[address(this)] = ds._balances[address(this)].add(
                    totalTaxAmount
                );
                ds._balances[sender] = ds._balances[sender].sub(amount);
                ds._balances[recipient] = ds._balances[recipient].add(
                    transferAmount
                );

                emit Transfer(sender, recipient, transferAmount);
                emit Transfer(sender, address(this), totalTaxAmount);

                ds._isSelling = false;
            }
        } else {
            ds._balances[sender] = ds._balances[sender].sub(amount);
            ds._balances[recipient] = ds._balances[recipient].add(amount);

            emit Transfer(sender, recipient, amount);
        }
    }
}
