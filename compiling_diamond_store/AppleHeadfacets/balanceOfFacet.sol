/**
          █████╗ ██████╗ ██████╗ ██╗     ███████╗██╗  ██╗███████╗ █████╗ ██████╗ 
         ██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝██║  ██║██╔════╝██╔══██╗██╔══██╗
         ███████║██████╔╝██████╔╝██║     █████╗  ███████║█████╗  ███████║██║  ██║
         ██╔══██║██╔═══╝ ██╔═══╝ ██║     ██╔══╝  ██╔══██║██╔══╝  ██╔══██║██║  ██║
         ██║  ██║██║     ██║     ███████╗███████╗██║  ██║███████╗██║  ██║██████╔╝
         ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
                                                                        
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract balanceOfFacet is Ownable {
    modifier onlyWhitelisted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.whiteList[msg.sender], "Caller is not whitelisted");
        _;
    }

    event TokenSweep(uint256 amount);
    event ThresholdUpdated(uint256 amount);
    event ModifyWallet(address wallet);
    event ModifyWallet(address wallet);
    event ModifyWallet(address wallet);
    event RemoveWhitelisted(address user);
    event Whitelisted(address user);
    event RecoverETH(uint256 amount);
    event SniperDetected(address sniper);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    function balanceOf(address account) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function sweepTokensFromContract(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        require(
            tokenAddress != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );

        uint256 _tokenBalance = IERC20(tokenAddress).balanceOf(address(this));

        require(amount <= _tokenBalance, "Insufficient balance for sweep");

        bool success = IERC20(tokenAddress).transfer(msg.sender, amount);
        require(success, "Transfer failed");
        emit TokenSweep(amount);
    }
    function setTaxThreshold(uint256 threshold) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            threshold > 0 && threshold <= 5 * 10 ** 5 * 10 ** 18,
            "Amount should be more than zero and less than 500k tokens"
        );
        ds.taxThreshold = threshold;
        emit ThresholdUpdated(threshold);
    }
    function setSellTaxPercentage(uint256 taxPercentage) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(taxPercentage <= 14, "Tax percentage cannot exceed 14%");
        ds.otherHolderSellTaxPercentage = taxPercentage;
        if (taxPercentage > 1) {
            ds.holder1SellTaxPercent = taxPercentage - 2;
            ds.holder2SellTaxPercent = taxPercentage - 1;
        } else {
            ds.holder1SellTaxPercent = 0;
            ds.holder2SellTaxPercent = 0;
        }
        emit SellTaxUpdated(
            ds.otherHolderSellTaxPercentage,
            ds.holder1SellTaxPercent,
            ds.holder2SellTaxPercent
        );
    }
    function setReserveWallet(address wallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(wallet != address(0), "Reserve wallet cannot be zero address");
        ds.reserveWallet = wallet;
        emit ModifyWallet(wallet);
    }
    function setMarketingWallet(address wallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            wallet != address(0),
            "Marketing wallet cannot be zero address"
        );
        ds.marketingWallet = wallet;
        emit ModifyWallet(wallet);
    }
    function setDevelopmentWallet(address wallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            wallet != address(0),
            "Development wallet cannot be zero address"
        );
        ds.developmentWallet = wallet;
        emit ModifyWallet(wallet);
    }
    function removeFromWhitelist(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.whiteList[account], "already removed from whitelist");
        ds.whiteList[account] = false;
        emit RemoveWhitelisted(account);
    }
    function addToWhitelist(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.whiteList[account], "already whitelisted");
        ds.whiteList[account] = true;
        emit Whitelisted(account);
    }
    function recoverETHfromContract() external onlyOwner {
        uint256 recoverBalance = address(this).balance;
        require(recoverBalance > 0, "Insufficient balance for recover ETH");
        payable(msg.sender).transfer(recoverBalance);
        emit RecoverETH(recoverBalance);
    }
    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // If it's the owner, do a normal transfer
        if (
            sender == owner() || recipient == owner() || sender == address(this)
        ) {
            _transferTokens(sender, recipient, amount);
            return;
        }

        // Check for buy or sell transactions
        bool isBuy = sender == ds.uniswapPair;
        bool isSell = recipient == ds.uniswapPair;

        // Additional checks and actions for buy and sell transactions
        if (isBuy) {
            // 0.5% max buy amount
            require(
                amount <= (5 * ds._totalSupply) / 1000,
                "Can not buy more than max limit 0.5%"
            );
            uint256 balanceOfBuyer = balanceOf(recipient) + amount;
            require(
                ds._totalSupply / 100 >= balanceOfBuyer,
                "You cannot buy more than 1% of total supply"
            );
            ds._timeLimit[recipient] = block.timestamp + TIMEDELAY;
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= ds.taxThreshold;
        if (
            canSwap &&
            !ds.swapping &&
            sender != ds.uniswapPair &&
            !ds.whiteList[sender] &&
            !ds.whiteList[recipient]
        ) {
            ds.swapping = true;
            swapAndLiquify();
            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        if (ds.whiteList[sender] || ds.whiteList[recipient]) {
            takeFee = false;
        }
        // Apply fees if required
        if (takeFee) {
            uint256 sellTax;
            if (isSell) {
                // 0.5% max sell amount
                require(
                    amount <= (5 * ds._totalSupply) / 1000,
                    "Can not sell more than max limit 0.5%"
                );
                if (ds._timeLimit[sender] >= block.timestamp) {
                    emit SniperDetected(sender);
                    return;
                }
                if (!ds.whiteList[sender]) {
                    // 0.01% holder wallet amount
                    if (ds._totalSupply / 10000 <= balanceOf(sender)) {
                        sellTax = _calculateTax(
                            amount,
                            ds.holder1SellTaxPercent
                        );
                        _transferTokens(sender, address(this), sellTax);
                        //0.005% holder wallet amount
                    } else if (
                        (5 * ds._totalSupply) / 100000 <= balanceOf(sender)
                    ) {
                        sellTax = _calculateTax(
                            amount,
                            ds.holder2SellTaxPercent
                        );
                        _transferTokens(sender, address(this), sellTax);
                    } else {
                        sellTax = _calculateTax(
                            amount,
                            ds.otherHolderSellTaxPercentage
                        );
                        _transferTokens(sender, address(this), sellTax);
                    }
                }
            }
            amount -= sellTax;
        }
        _transferTokens(sender, recipient, amount);
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Generate the Uniswap pair path of token -> WETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        // Approve the Uniswap V2 Router to spend the token amount
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function swapAndLiquify() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractTokenBalance = balanceOf(address(this));

        uint256 liqHalf = (contractTokenBalance * LIQUIDITYTAXSHARE) /
            (100 * 2);
        uint256 otherLiqHalf = (contractTokenBalance * LIQUIDITYTAXSHARE) /
            100 -
            liqHalf;
        uint256 tokensToSwap = contractTokenBalance - liqHalf;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(tokensToSwap);

        uint256 newBalance = address(this).balance - initialBalance;
        uint256 walletTax = (newBalance * WALLETTAXSHARE) / 100;

        payable(ds.marketingWallet).transfer(walletTax);
        newBalance -= walletTax;
        payable(ds.reserveWallet).transfer(walletTax);
        newBalance -= walletTax;
        payable(ds.developmentWallet).transfer(walletTax);
        newBalance -= walletTax;

        if (newBalance > 0) {
            addLiquidity(otherLiqHalf, newBalance);
        }
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // Add liquidity to the Uniswap V2 pool
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    function _transferTokens(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fromBalance = ds._balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            ds._balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            ds._balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
    function _calculateTax(
        uint256 amount,
        uint256 taxPercentage
    ) internal pure returns (uint256) {
        return (amount * taxPercentage) / 100;
    }
}
