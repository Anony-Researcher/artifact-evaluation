// SPDX-License-Identifier: MIT
/** 

Website: https://www.altvm.com/

AltVM is a token protocol designed to facilitate seamless interoperability among diverse Virtual Machines (VMs) 
within the blockchain ecosystem. Utilizing advanced cryptographic techniques and decentralized governance mechanisms, 
AltVM acts as a bridging protocol, enabling efficient communication and data exchange across disparate VM environments. 
By providing a standardized framework for inter-VM interactions, AltVM addresses the challenges of siloed VM ecosystems, 
promoting greater collaboration and synergy among blockchain platforms.

In the realm of decentralized computing, the proliferation of various Virtual Machines (VMs) has presented a significant challenge: 
the lack of interoperability between disparate platforms. Each blockchain network operates within its own VM environment, 
leading to isolated ecosystems with limited communication capabilities. Recognizing the need for a solution to bridge these divides, 
AltVM emerged as a pioneering token protocol.

Rooted in advanced cryptographic principles and decentralized governance, AltVM serves as a universal bridge connecting different VMs 
within the blockchain landscape. Through its protocol, AltVM establishes standardized communication channels and data exchange 
mechanisms, enabling seamless interoperability among diverse platforms.

The journey of AltVM is characterized by technical innovation and collaborative effort. Drawing upon expertise from cryptography, 
distributed systems, and blockchain technology, the development team behind AltVM meticulously crafted a protocol capable of 
transcending the boundaries of individual VM ecosystems.

As AltVM gains traction within the academic and technical communities, its impact on the blockchain ecosystem becomes increasingly 
evident. Through academic research, peer-reviewed publications, and collaborative partnerships with leading blockchain projects, 
AltVM continues to advance the frontier of interoperability, driving forward the evolution of decentralized technology.

With each new integration and protocol enhancement, AltVM moves closer to realizing its vision of a truly interconnected and 
interoperable blockchain ecosystem. As the academic and technical community rally behind the mission of AltVM, the future of 
decentralized computing appears brighter than ever before.

**/

pragma solidity 0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IDexFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

uint8 constant _decimals = 9;
string constant _name = unicode"Alternative VM Bridging Protocol";
string constant _symbol = unicode"AltVM";
uint256 constant _tTotal = 100000000 * 10 ** _decimals;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct DappCredits {
        uint256 buy;
        uint256 sell;
        uint256 credits;
    }

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isExcludedFromFee;
        mapping(address => uint256) _holderLastTransferTimestamp;
        bool transferDelayEnabled;
        uint256 _initBuyTax;
        uint256 _initSellTax;
        uint256 _finalBuyTax;
        uint256 _finalSellTax;
        uint256 _reduceBuyTaxAt;
        uint256 _reduceSellTaxAt;
        uint256 _preventSwapBefore;
        uint256 _buyCount;
        uint256 _maxTxAmount;
        uint256 _maxWalletSize;
        uint256 _taxSwapThreshold;
        uint256 _maxTaxSwap;
        address payable _taxWallet;
        address payable _teamWallet;
        IDexRouter dexRouter;
        address lpPair;
        bool tradingOpen;
        bool inSwap;
        bool swapEnabled;
        uint256 _launchBlock;
        uint256 _freeCredit;
        mapping(address => undefined) dappCredits;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
