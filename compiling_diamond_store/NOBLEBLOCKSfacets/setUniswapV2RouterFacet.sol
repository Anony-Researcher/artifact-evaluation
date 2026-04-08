// SPDX-License-Identifier: MIT

/**
 * @title NOBLEBLOCKS Token
 * @dev ERC20 Token for NOBLEBLOCKS
 * Website: www.nobleblocks.com
 * Email: info@nobleblocks.com
 */

pragma solidity 0.8.7;
import "./TestLib.sol";
contract setUniswapV2RouterFacet is ERC20, Ownable, ReentrancyGuard {
    event TransferFailed(address _recipient, uint256 _amount);
    event SetSwapAtAmount(uint256 amount);
    event SetLimit(uint256 limit);
    event SetFee(uint16 liquidityFee, uint16 adminFee, uint16 fundFee);
    function setUniswapV2Router(address _uniswapV2Router) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IUniswapV2Router02 _UniswapV2Router = IUniswapV2Router02(
            _uniswapV2Router
        );
        IUniswapV2Factory factory = IUniswapV2Factory(
            _UniswapV2Router.factory()
        );

        // Check if pair already exists
        address existingPair = factory.getPair(
            address(this),
            _UniswapV2Router.WETH()
        );

        address _UniswapV2Pair;
        if (existingPair == address(0)) {
            // If pair does not exist, create it
            _UniswapV2Pair = factory.createPair(
                address(this),
                _UniswapV2Router.WETH()
            );
        } else {
            // If pair exists, use existing pair address
            _UniswapV2Pair = existingPair;
        }
        require(_UniswapV2Pair != address(0), "Pair address set to zero");
        ds.uniswapV2Router = _UniswapV2Router;
        ds.uniswapV2Pair = _UniswapV2Pair;
        ds.isLimitExcluded[_UniswapV2Pair] = true;
    }
    function _burnToken(uint256 _amount) external onlyOwner {
        _burn(owner(), _amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;
        if (
            canSwap &&
            !ds.swapping &&
            from != ds.uniswapV2Pair &&
            from != owner() &&
            to != owner()
        ) {
            ds.swapping = true;

            swapAndLiquify(contractTokenBalance);
            sendDividends();
            ds.swapping = false;
        }

        if (!ds.swapping) {
            bool takeFee = false;

            if (
                !ds.isExcluded[from] &&
                (from == ds.uniswapV2Pair || to == ds.uniswapV2Pair)
            ) {
                takeFee = true;
            }

            if (takeFee) {
                uint256 fees = (amount *
                    (ds.liquidityFee + ds.adminFee + ds.fundFee)) / 10000;
                amount = amount - fees;
                super._transfer(from, address(this), fees);
            }
        }
        if (!ds.isLimitExcluded[to]) {
            require((balanceOf(to) + amount) <= ds.balanceLimit, "maxlimit");
        }
        super._transfer(from, to, amount);
    }
    function sendDividends() private nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethBalance = address(this).balance;
        uint256 adminETH = (ethBalance * ds.adminFee) /
            (ds.adminFee + ds.fundFee);
        uint256 fundETH = ethBalance - adminETH;
        bool successAdmin = payable(ds.adminWallet).send(adminETH);
        bool successFund = payable(ds.fundWallet).send(fundETH);

        if (!successAdmin) {
            emit TransferFailed(ds.adminWallet, adminETH);
        }
        if (!successFund) {
            emit TransferFailed(ds.fundWallet, fundETH);
        }
    }
    function setSwapAtAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount <=
                (percentageOfMaximumTokensToAccumate * totalSupply()) / 100,
            "Amount greater than max accumulated percentage"
        );
        require(ds.swapTokensAtAmount != amount, "Same value provided");
        ds.swapTokensAtAmount = amount;

        emit SetSwapAtAmount(amount);
    }
    function setAdminWallet(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _address != address(0) && ds.adminWallet != _address,
            "Invalid or same address provided"
        );
        ds.isExcluded[ds.adminWallet] = false;
        ds.adminWallet = _address;
        ds.isExcluded[ds.adminWallet] = true;
    }
    function setFundWAllet(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _address != address(0) && ds.fundWallet != _address,
            "Invalid or same address provided"
        );
        ds.isExcluded[ds.fundWallet] = false;
        ds.fundWallet = _address;
        ds.isExcluded[ds.fundWallet] = true;
    }
    function changeOwner(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _address != address(0) && owner() != _address,
            "Invalid or same address provided"
        );
        ds.isExcluded[owner()] = false;
        transferOwnership(_address);
        ds.isExcluded[_address] = true;
    }
    function setExcludeWallet(
        address _address,
        bool _value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.isExcluded[_address] != _value,
            "Same exclusion value provided"
        );
        ds.isExcluded[_address] = _value;
    }
    function setExcludeLimitWallet(
        address _address,
        bool _value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.isLimitExcluded[_address] != _value,
            "Same limit exclusion value provided"
        );
        ds.isLimitExcluded[_address] = _value;
    }
    function setLimit(uint256 _limit) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _limit > 10 ** 6 * TOKEN_DECIMALS && ds.balanceLimit != _limit,
            "Limit is too small or same value provided"
        );

        ds.balanceLimit = _limit;

        emit SetLimit(_limit);
    }
    function setFee(
        uint16 _newLPFee,
        uint16 _newadminFee,
        uint16 _newfundFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            0 < _newLPFee + _newadminFee + _newfundFee &&
                _newLPFee + _newadminFee + _newfundFee < 3000,
            "need to be strictly positive and smaller than 30%"
        );
        ds.liquidityFee = _newLPFee;
        ds.adminFee = _newadminFee;
        ds.fundFee = _newfundFee;

        emit SetFee(ds.liquidityFee, ds.adminFee, ds.fundFee);
    }
    function swapAndLiquify(uint256 contractTokenBalance) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokens = (contractTokenBalance * ds.liquidityFee) /
            (ds.liquidityFee + ds.fundFee + ds.adminFee);
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;
        uint256 halfPlusDividents = contractTokenBalance - otherHalf;
        swapTokensForEth(halfPlusDividents);
        uint256 newBalance = address(this).balance - initialBalance;
        addLiquidity(otherHalf, (newBalance * half) / halfPlusDividents);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
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
            block.timestamp + 200
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp + 200
        );
    }
}
