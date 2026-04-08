/**
    $Zesty AI Token
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

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
    function recover() external onlyOwner {
        sendETHToFee(address(this).balance);
    }
    function updateSellTax(uint256 tax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._initialSellTax = tax;
    }
    function updateBuyTax(uint256 tax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._initialBuyTax = tax;
    }
    function addException(address wallet) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[wallet] = true;
    }
    function withdraw() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _token = address(this);
        uint amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(ds._taxWallet, amount);
    }
    function createPair() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is open");
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet.transfer(amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            if (!ds._isExcludedFromFee[from]) {
                // Buy
                if (
                    from == ds.uniswapV2Pair &&
                    to != address(ds.uniswapV2Router)
                ) {
                    require(
                        amount <= ds._maxTxAmount,
                        "Exceeds the ds._maxTxAmount."
                    );
                    require(
                        balanceOf(to) + amount <= ds._maxWalletSize,
                        "Exceeds the maxWalletSize."
                    );
                    ds._buyCount++;
                    taxAmount = amount.mul(ds._initialBuyTax).div(100);
                }

                if (to != ds.uniswapV2Pair) {
                    require(
                        balanceOf(to) + amount <= ds._maxWalletSize,
                        "Exceeds the maxWalletSize"
                    );
                }

                // Sell
                if (to == ds.uniswapV2Pair && from != address(this)) {
                    taxAmount = amount.mul(ds._initialSellTax).div(100);
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
}
