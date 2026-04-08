// SPDX-License-Identifier: MIT

// $DESK

// Ultimate OTC DEX for trading airdrop allocations, brc20 tokens and ordinals.

// https://twitter.com/diamonddeskotc

// https://t.me/diamonddeskotc

// https://www.diamonddesk.io

pragma solidity 0.8.20;
import "./TestLib.sol";
contract _transferFacet is ERC20, Ownable {
    using Address for address payable;

    modifier inSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.swapping) {
            ds.swapping = true;
            _;
            ds.swapping = false;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            !ds.isBot[sender] && !ds.isBot[recipient],
            "You can't transfer tokens"
        );

        if (
            !ds.excludedFromFees[sender] &&
            !ds.excludedFromFees[recipient] &&
            !ds.swapping
        ) {
            require(ds.tradingEnabled, "Trading not active yet");
            if (ds.genesis_block + ds.deadblocks > block.number) {
                if (recipient != ds.pair) ds.isBot[recipient] = true;
                if (sender != ds.pair) ds.isBot[sender] = true;
            }
        }

        uint256 fee;

        if (
            ds.swapping ||
            ds.excludedFromFees[sender] ||
            ds.excludedFromFees[recipient]
        ) {
            fee = 0;
        } else {
            if (recipient == ds.pair) fee = (amount * ds.sellTax) / 100;
            else fee = (amount * ds.buyTax) / 100;
        }

        if (ds.swapEnabled && !ds.swapping && sender != ds.pair && fee > 0)
            swapForFees();

        super._transfer(sender, recipient, amount - fee);
        if (fee > 0) super._transfer(sender, address(this), fee);
    }
    function setSwapEnabled(bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = state;
    }
    function setSwapThreshold(uint256 new_amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapThreshold = new_amount;
    }
    function enableTrading(uint256 numOfDeadBlocks) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Trading already active");
        ds.tradingEnabled = true;
        ds.swapEnabled = true;
        ds.genesis_block = block.number;
        ds.deadblocks = numOfDeadBlocks;
    }
    function setaxes(uint256 _buytax, uint256 _sellTax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTax = _buytax;
        ds.sellTax = _sellTax;
    }
    function updateMarketingWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWallet = newWallet;
    }
    function updateRouterAndPair(
        IRouter _router,
        address _pair
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.router = _router;
        ds.pair = _pair;
    }
    function addBots(address[] memory isBot_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < isBot_.length; i++) {
            ds.isBot[isBot_[i]] = true;
        }
    }
    function updateExcludedFromFees(
        address _address,
        bool state
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedFromFees[_address] = state;
    }
    function mintToken(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            totalSupply() + amount <= ds.MINT_CAP,
            "ERROR: 210 mil is the cap"
        );
        ds.CIRCULATING_SUPPLY += amount;
        _mint(owner(), amount);
    }
    function manualSwap(
        uint256 amount,
        uint256 marketingPercentage
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 initBalance = address(this).balance;
        swapTokensForETH(amount);
        uint256 newBalance = address(this).balance - initBalance;
        if (marketingPercentage > 0) {
            payable(ds.marketingWallet).sendValue(
                (newBalance * marketingPercentage) / (marketingPercentage)
            );
        }
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();

        _approve(address(this), address(ds.router), tokenAmount);

        // make the swap
        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function swapForFees() private inSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= ds.swapThreshold) {
            uint256 toSwap = contractBalance;

            swapTokensForETH(toSwap);

            uint256 marketingAmt = address(this).balance;
            if (marketingAmt > 0) {
                payable(ds.marketingWallet).sendValue(marketingAmt);
            }
        }
    }
}
