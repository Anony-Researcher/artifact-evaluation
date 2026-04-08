/***********************************************************************
//
//  
// ██╗   ██╗ ██████╗ ████████╗███████╗ ██████╗██╗  ██╗     █████╗ ██╗
// ██║   ██║██╔═══██╗╚══██╔══╝██╔════╝██╔════╝██║  ██║    ██╔══██╗██║
// ██║   ██║██║   ██║   ██║   █████╗  ██║     ███████║    ███████║██║
// ╚██╗ ██╔╝██║   ██║   ██║   ██╔══╝  ██║     ██╔══██║    ██╔══██║██║
//  ╚████╔╝ ╚██████╔╝   ██║   ███████╗╚██████╗██║  ██║    ██║  ██║██║
//   ╚═══╝   ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝
//
//                               
***********************************************************************/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event _changePair(address newLpPair);
    event _toggleCanSwapFees(bool enabled);
    event _changeWallets(address newBuy);
    event _setPresaleAddress(address account, bool enabled);
    function totalSupply() external pure override returns (uint256) {
        if (_totalSupply == 0) {
            revert();
        }
        return _totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        if (_totalSupply == 0) {
            revert();
        }
        return _decimals;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function name() external pure override returns (string memory) {
        return _name;
    }
    function getOwner() external view override returns (address) {
        return owner();
    }
    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[holder][spender];
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balance[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._allowances[sender][msg.sender] != type(uint256).max) {
            ds._allowances[sender][msg.sender] -= amount;
        }
        return _transfer(sender, recipient, amount);
    }
    function setNoFeeWallet(address account, bool enabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._noFee[account] = enabled;
    }
    function changeLpPair(address newPair) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isLpPair[newPair] = true;
        emit _changePair(newPair);
    }
    function toggleCanSwapFees(bool yesno) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.canSwapFees != yesno, "Bool is the same");
        ds.canSwapFees = yesno;
        emit _toggleCanSwapFees(yesno);
    }
    function changeWallets(address newBuy) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newBuy != address(0), "Address Zero");
        ds.marketingAddress = payable(newBuy);
        emit _changeWallets(newBuy);
    }
    function setPresaleAddress(address presale, bool yesno) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isPresaleAddress[presale] != yesno, "Already Setup");
        ds.isPresaleAddress[presale] = yesno;
        ds._noFee[presale] = yesno;
        emit _setPresaleAddress(presale, yesno);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (is_sell(from, to) && !ds.inSwap && canSwap(from, to)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= swapThreshold) {
                if (ds.totalAllocation > 0)
                    internalSwap(
                        (contractTokenBalance * (ds.totalAllocation)) / 100
                    );
            }
        }

        if (ds._noFee[from] || ds._noFee[to]) {
            takeFee = false;
        }
        ds.balance[from] -= amount;
        uint256 amountAfterFee = (takeFee)
            ? takeTaxes(from, is_buy(from, to), is_sell(from, to), amount)
            : amount;
        ds.balance[to] += amountAfterFee;
        emit Transfer(from, to, amountAfterFee);

        return true;
    }
    function is_sell(address ins, address out) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool _is_sell = ds.isLpPair[out] && !ds.isLpPair[ins];
        return _is_sell;
    }
    function canSwap(address ins, address out) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool canswap = ds.canSwapFees &&
            !ds.isPresaleAddress[ins] &&
            !ds.isPresaleAddress[out];
        return canswap;
    }
    function internalSwap(uint256 contractTokenBalance) internal inSwapFlag {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.swapRouter.WETH();

        if (
            ds._allowances[address(this)][address(ds.swapRouter)] !=
            type(uint256).max
        ) {
            ds._allowances[address(this)][address(ds.swapRouter)] = type(
                uint256
            ).max;
        }

        try
            ds.swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return;
        }
        bool success;
        uint256 mktAmount = address(this).ds.balance;
        if (mktAmount > 0)
            (success, ) = ds.marketingAddress.call{
                value: mktAmount,
                gas: 35000
            }("");
    }
    function takeTaxes(
        address from,
        bool isbuy,
        bool issell,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee;
        if (isbuy) fee = ds.buyfee;
        else if (issell) fee = ds.sellfee;
        else fee = ds.transferfee;
        if (fee == 0) return amount;
        uint256 feeAmount = (amount * fee) / fee_denominator;
        if (feeAmount > 0) {
            ds.balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }
        return amount - feeAmount;
    }
    function is_buy(address ins, address out) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool _is_buy = !ds.isLpPair[out] && ds.isLpPair[ins];
        return _is_buy;
    }
    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        ds._allowances[sender][spender] = amount;
    }
}
