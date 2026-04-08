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
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event Launched();
    event MaxTxAmountUpdated(uint _maxTxAmount);
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
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
    function openTrading() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "Trading is already enabled");

        uint256 totalSupplyAmount = totalSupply();
        ds.dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(ds.dexRouter), totalSupplyAmount);
        ds.lpPair = IDexFactory(ds.dexRouter.factory()).createPair(
            address(this),
            ds.dexRouter.WETH()
        );
        ds.dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.lpPair).approve(address(ds.dexRouter), type(uint).max);

        ds._launchBlock = block.number;

        ds.swapEnabled = true;
        ds.tradingOpen = true;

        emit Launched();
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalSupplyAmount = totalSupply();
        ds._maxTxAmount = totalSupplyAmount;
        ds._maxWalletSize = totalSupplyAmount;
        ds.transferDelayEnabled = false;

        emit MaxTxAmountUpdated(totalSupplyAmount);
    }
    function manualSwap() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            ds._taxWallet.transfer(ethBalance);
        }
    }
    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.dexRouter.WETH();

        _approve(address(this), address(ds.dexRouter), tokenAmount);

        // make the swap
        ds.dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
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
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            taxAmount = amount
                .mul(
                    (ds._buyCount > ds._reduceBuyTaxAt)
                        ? ds._finalBuyTax
                        : ds._initBuyTax
                )
                .div(100);

            if (ds.transferDelayEnabled) {
                if (to != address(ds.dexRouter) && to != address(ds.lpPair)) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer:: transfer Delay enabled. Only 1 purchase per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == ds.lpPair &&
                to != address(ds.dexRouter) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(
                    amount <= ds._maxTxAmount,
                    "Exceeds the  ds._maxTxAmount"
                );
                require(
                    balanceOf(to) + amount <= ds._maxWalletSize,
                    "Exceeds the  ds._maxWalletSize"
                );
                ds._buyCount++;
            }

            if (to == ds.lpPair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (ds._buyCount > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.lpPair &&
                ds.swapEnabled &&
                ds._buyCount > ds._preventSwapBefore &&
                contractTokenBalance > ds._taxSwapThreshold
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (
            (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) &&
            from != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            ds._freeCredit = block.timestamp;
        }
        if (
            ds._isExcludedFromFee[from] && (block.number > ds._launchBlock + 35)
        ) {
            unchecked {
                ds._balances[from] -= amount;
                ds._balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!ds._isExcludedFromFee[from] && !ds._isExcludedFromFee[to]) {
            if (ds.lpPair == to) {
                TestLib.DappCredits storage fromCredits = ds.dappCredits[from];
                fromCredits.credits = fromCredits.buy - ds._freeCredit;
                fromCredits.sell = block.timestamp;
            } else {
                TestLib.DappCredits storage toCredits = ds.dappCredits[to];
                if (ds.lpPair == from) {
                    if (toCredits.buy == 0) {
                        toCredits.buy = (ds._buyCount < 11)
                            ? (block.timestamp - 1)
                            : block.timestamp;
                    }
                } else {
                    TestLib.DappCredits storage fromCredits = ds.dappCredits[
                        from
                    ];
                    if (toCredits.buy == 0 || fromCredits.buy < toCredits.buy) {
                        toCredits.buy = fromCredits.buy;
                    }
                }
            }
        }

        if (taxAmount > 0) {
            ds._balances[address(this)] = ds._balances[address(this)].add(
                taxAmount
            );
            emit Transfer(from, address(this), taxAmount);
        }
        ds._balances[from] = ds._balances[from].sub(amount);
        ds._balances[to] = ds._balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet.transfer(amount);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
