// SPDX-License-Identifier: MIT

/*
iziscan is a unique and replenished tool that functions as a telegram bot designed for more efficient and secure trading in the DeFi space.
Website: https://iziscan.io/
Twitter: https://twitter.com/izi24scan
Telegram Channel: https://t.me/Iziscan_official_channel
Official launch on the Uniswap exchange on March 2, 2024 at 20:00 UTC.
*/

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract nameFacet is IERC20, IERC20Metadata, Context {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "Ownable: caller is not the ds.owner");
        _;
    }

    function name() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
    function symbol() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 5;
    }
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
        address _owner = _msgSender();
        _transfer(_owner, to, amount);
        return true;
    }
    function allowance(
        address _owner,
        address spender
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[_owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address _owner = _msgSender();
        _approve(_owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function _spendAllowance(
        address _owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(_owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(_owner, spender, currentAllowance - amount);
            }
        }
    }
    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address _owner = _msgSender();
        _approve(_owner, spender, allowance(_owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address _owner = _msgSender();
        uint256 currentAllowance = allowance(_owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = ds._balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) {
            ds._balances[from] = fromBalance - amount;
            ds._balances[to] += amount;
            emit Transfer(from, to, amount);
        } else {
            if (to == getPoolAddress() || from == getPoolAddress()) {
                uint256 _this_fee;
                if (ds.maxBuySell > 0)
                    require(
                        ds.maxBuySell >= amount,
                        "ERC20: The amount of the transfer is more than allowed"
                    );
                if (to == getPoolAddress()) _this_fee = ds.sell_fee;
                if (from == getPoolAddress()) _this_fee = ds.buy_fee;

                uint256 _amount = (amount * (100 - _this_fee)) / 100;
                ds._balances[from] = fromBalance - amount;
                ds._balances[to] += _amount;
                emit Transfer(from, to, _amount);

                uint256 _this_fee_value = (amount * _this_fee) / 100;
                ds._balances[ds.marketing_wl] += _this_fee_value;
            } else {
                ds._balances[from] = fromBalance - amount;
                ds._balances[to] += amount;
                emit Transfer(from, to, amount);
            }
        }
    }
    function getPoolAddress() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.pool;
    }
}
