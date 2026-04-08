// SPDX-License-Identifier: MIT

/*

.................................................................
..####...##...##..######..######..######...........####...######.
.##......##...##....##....##........##............##..##....##...
..####...##.#.##....##....####......##............######....##...
.....##..#######....##....##........##............##..##....##...
..####....##.##...######..##........##............##..##..######.
.................................................................
                                                                     
 Telegram: https://t.me/SwiftAIB
 Twitter: https://x.com/swift_aitoken?s=21
 Website: https://swiftaibot.com/
 SwiftAI: https://t.me/SwiftAIIBOT

*/

pragma solidity 0.8.22;
import "./TestLib.sol";
contract _transferFacet is ERC20 {
    using Address for address payable;

    modifier lockSwapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }
    modifier inSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.swapping) {
            ds.swapping = true;
            _;
            ds.swapping = false;
        }
    }

    event SwapEnabled();
    event SwapThresholdUpdated();
    event Launched();
    event BuyTaxesUpdated();
    event SellTaxesUpdated();
    event MarketingWalletUpdated();
    event DevelopmentWalletUpdated();
    event ExcludedFromFeesUpdated();
    event MaxTxAmountUpdated();
    event MaxWalletAmountUpdated();
    event TransferForeignToken(address token, uint256 amount);
    event StuckEthersCleared();
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "Transfer amount must be greater than zero");

        if (
            !ds.excludedFromFees[sender] &&
            !ds.excludedFromFees[recipient] &&
            !ds.swapping
        ) {
            require(ds.launched, "Trading not active yet");
            require(
                amount <= ds.maxTxAmount,
                "You are exceeding ds.maxTxAmount"
            );
            if (recipient != ds.pair) {
                require(
                    balanceOf(recipient) + amount <= ds.maxWalletAmount,
                    "You are exceeding ds.maxWalletAmount"
                );
            }
        }

        uint256 fee;

        if (
            ds.swapping ||
            ds.excludedFromFees[sender] ||
            ds.excludedFromFees[recipient]
        ) fee = 0;
        else {
            if (recipient == ds.pair) fee = (amount * ds.totSellTax) / 1000;
            else if (sender == ds.pair) fee = (amount * ds.totBuyTax) / 1000;
            else fee = 0;
        }

        if (ds.swapEnabled && !ds.swapping && sender != ds.pair && fee > 0)
            swapForFees();

        super._transfer(sender, recipient, amount - fee);
        if (fee > 0) super._transfer(sender, address(this), fee);
    }
    function setSwapEnabled(bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // to be used only in case of dire emergency
        ds.swapEnabled = state;
        emit SwapEnabled();
    }
    function setSwapThreshold(uint256 new_amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            new_amount >= 10000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            new_amount <= 30000000,
            "Swap amount cannot be higher than 3% total supply."
        );
        ds.swapThreshold = new_amount * (10 ** 18);
        emit SwapThresholdUpdated();
    }
    function launch() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.launched, "Trading already active");
        ds.launched = true;
        ds.swapEnabled = true;
        emit Launched();
    }
    function setBuyTaxes(
        uint256 _marketing,
        uint256 _development
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTaxes = TestLib.Taxes(_marketing, _development);
        ds.totBuyTax = _marketing + _development;
        require(ds.totBuyTax <= 20, "Total buy fees cannot be greater than 2%");
        emit BuyTaxesUpdated();
    }
    function setSellTaxes(
        uint256 _marketing,
        uint256 _development
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellTaxes = TestLib.Taxes(_marketing, _development);
        ds.totSellTax = _marketing + _development;
        require(
            ds.totSellTax <= 20,
            "Total sell fees cannot be greater than 2%"
        );
        require(ds.totSellTax >= 10, "Total sell fees cannot beless  than 1%");
        emit SellTaxesUpdated();
    }
    function setMarketingWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedFromFees[ds.marketingWallet] = false;
        require(
            newWallet != address(0),
            "Marketing Wallet cannot be zero address"
        );
        ds.marketingWallet = newWallet;
        emit MarketingWalletUpdated();
    }
    function setDevelopmentWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedFromFees[ds.developmentWallet] = false;
        require(
            newWallet != address(0),
            "Development Wallet cannot be zero address"
        );
        ds.developmentWallet = newWallet;
        emit DevelopmentWalletUpdated();
    }
    function setExcludedFromFees(
        address _address,
        bool state
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedFromFees[_address] = state;
        emit ExcludedFromFeesUpdated();
    }
    function setMaxTxAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount >= 100000, "Cannot set maxSell lower than 0.1%");
        ds.maxTxAmount = amount * (10 ** 18);
        emit MaxTxAmountUpdated();
    }
    function setMaxWalletAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount >= 250000, "Cannot set maxSell lower than 0.25%");
        ds.maxWalletAmount = amount * (10 ** 18);
        emit MaxWalletAmountUpdated();
    }
    function withdrawStuckTokens(
        address _token,
        address _to
    ) external onlyOwner returns (bool _sent) {
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }
    function clearStuckEthers(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer((amountETH * amountPercentage) / 100);
        emit StuckEthersCleared();
    }
    function unclog() public onlyOwner lockSwapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        swapTokensForETH(balanceOf(address(this)));

        uint256 ethBalance = address(this).balance;
        uint256 ethMarketing = ethBalance / 2;
        uint256 ethDevelopment = ethBalance - ethMarketing;

        bool success;
        (success, ) = address(ds.marketingWallet).call{value: ethMarketing}("");

        (success, ) = address(ds.developmentWallet).call{value: ethDevelopment}(
            ""
        );
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

            uint256 initialBalance = address(this).balance;

            swapTokensForETH(toSwap);

            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 marketingAmt = (deltaBalance * 50) / 100;
            uint256 developmentAmt = deltaBalance - marketingAmt;

            if (marketingAmt > 0) {
                payable(ds.marketingWallet).sendValue(marketingAmt);
            }

            if (developmentAmt > 0) {
                payable(ds.developmentWallet).sendValue(developmentAmt);
            }
        }
    }
}
