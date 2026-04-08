// SPDX-License-Identifier: MIT

/*

This contract is a safe utility token deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/standard

*/

pragma solidity 0.8.25;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address account, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed account, address indexed spender, uint256 amount);
}

interface IFactoryStandard {
    function getPair() external view returns (address);
}

interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Standard is IERC20 {
    address public owner;
    address public feeReceiver;
    address public immutable wETH;
    address public immutable router;
    address public immutable utilReceiver;
    address public immutable liquidityPair;
    string public name;
    string public symbol;
    string public socials;
    uint8 public immutable decimals;
    uint256 public buyFee;
    uint256 public sellFee;
    uint256 public maxWallet;
    uint256 public immutable transferFee;
    uint256 public immutable totalSupply;
    uint256 public immutable swapBackMin;
    mapping(address => bool) public limitExempt;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(address ow, string memory na, string memory sy, uint256 tS, uint256 lS, uint256 mW, uint256 bF, uint256 sF) {
        owner = ow;
        feeReceiver = ow;
        wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        utilReceiver = 0xFee07f5Cd6ab297F6f5538816dE0Ef7289420Fee;
        liquidityPair = IFactoryStandard(msg.sender).getPair();
        name = na;
        symbol = sy;
        buyFee = bF;
        sellFee = sF;
        decimals = 18;
        maxWallet = mW;
        transferFee = 0;
        totalSupply = tS;
        swapBackMin = tS / 1000;
        balanceOf[liquidityPair] = lS;
        emit Transfer(address(0), liquidityPair, lS);
        if (lS < tS) {
            uint256 teamSupply = tS - lS;
            balanceOf[owner] = teamSupply;
            emit Transfer(address(0), owner, teamSupply);
        }
        limitExempt[router] = true;
        allowance[address(this)][router] = type(uint256).max;
    }

    receive() external payable { }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfers(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= amount;
        }
        _transfers(from, to, amount);
        return true;
    }

    function updateSocials(string calldata newSocials) external onlyOwner {
        socials = newSocials;
    }

    function updateMaxWallet(uint256 newMaxWallet) external onlyOwner {
        require(newMaxWallet >= totalSupply * 5 / 1000);
        require(newMaxWallet <= totalSupply);
        maxWallet = newMaxWallet;
    }

    function updateLimitExempt(address account) external onlyOwner {
        require(maxWallet > 0);
        limitExempt[account] = !limitExempt[account];
    }

    function updateFeeReceiver(address newFeeReceiver) external onlyOwner {
        require(newFeeReceiver != address(0));
        feeReceiver = newFeeReceiver;
    }

    function updateOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership(bool trueToConfirm) external onlyOwner {
        require(trueToConfirm);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function updateFees(uint256 newBuyFee, uint256 newSellFee) external onlyOwner {
        require(newBuyFee <= 15);
        require(newSellFee <= 15);
        _swapBack();
        withdrawFees();
        buyFee = newBuyFee > 0 ? newBuyFee : 1;
        sellFee = newSellFee > 0 ? newSellFee : 1;
    }

    function withdrawFees() public {
        uint256 amount = address(this).balance;
        if (amount > 0) {
            uint256 totalFee = (buyFee + sellFee) * 10 / 2;
            if (totalFee == 10) {
                (bool success,) = utilReceiver.call{value: amount}("");
                require(success);
            } else {
                uint256 utilAmount = amount * 10 / totalFee;
                (bool success,) = utilReceiver.call{value: utilAmount}("");
                require(success);
                (success,) = feeReceiver.call{value: amount - utilAmount}("");
                require(success);
            }
        }
    }

    function _transfers(address from, address to, uint256 amount) internal {
        require(amount > 0);
        balanceOf[from] -= amount;
        if (to == liquidityPair) {
            if (from != address(this)) {
                _swapBack();
                uint256 feeAmount = amount * sellFee / 100;
                _swap(from, to, feeAmount, amount - feeAmount);
            } else {
                _transfer(from, to, amount);
            }
        } else if (from == liquidityPair) {
            _preSwap(from, to, amount, buyFee);
        } else {
            if (_isPair(to)) {
                _swapBack();
                _preSwap(from, to, amount, sellFee);
            } else if (_isPair(from)) {
                _preSwap(from, to, amount, buyFee);
            } else {
                require(balanceOf[to] + amount <= maxWallet || limitExempt[to] || from == owner || from == router);
                _transfer(from, to, amount);
            }
        }
    }

    function _preSwap(address from, address to, uint256 amount, uint256 fee) internal {
        uint256 feeAmount = amount * fee / 100;
        uint256 toAmount = amount - feeAmount;
        require(balanceOf[to] + toAmount <= maxWallet || limitExempt[to]);
        _swap(from, to, feeAmount, toAmount);
    }

    function _swap(address from, address to, uint256 feeAmount, uint256 toAmount) internal {
        balanceOf[address(this)] += feeAmount;
        balanceOf[to] += toAmount;
        emit Transfer(from, address(this), feeAmount);
        emit Transfer(from, to, toAmount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _isPair(address account) internal view returns (bool isPair) {
        if (account.code.length > 0) {
            (isPair,) = account.staticcall(abi.encodeWithSelector(0x0dfe1681));
        }
    }

    function _swapBack() internal {
        uint256 swapBackAmount = balanceOf[address(this)];
        if (swapBackAmount >= swapBackMin) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = wETH;
            IUniswapV2Router(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapBackAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }
}