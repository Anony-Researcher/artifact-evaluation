// SPDX-License-Identifier: MIT

/*

This contract is a safe utility token deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/standard

*/

pragma solidity 0.8.25;
import "./TestLib.sol";
contract approveFacet is IERC20 {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfers(msg.sender, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.allowance[from][msg.sender] != type(uint256).max) {
            ds.allowance[from][msg.sender] -= amount;
        }
        _transfers(from, to, amount);
        return true;
    }
    function _transfers(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0);
        ds.balanceOf[from] -= amount;
        if (to == ds.liquidityPair) {
            if (from != address(this)) {
                _swapBack();
                uint256 feeAmount = (amount * ds.sellFee) / 100;
                _swap(from, to, feeAmount, amount - feeAmount);
            } else {
                _transfer(from, to, amount);
            }
        } else if (from == ds.liquidityPair) {
            _preSwap(from, to, amount, ds.buyFee);
        } else {
            if (_isPair(to)) {
                _swapBack();
                _preSwap(from, to, amount, ds.sellFee);
            } else if (_isPair(from)) {
                _preSwap(from, to, amount, ds.buyFee);
            } else {
                require(
                    ds.balanceOf[to] + amount <= ds.maxWallet ||
                        ds.limitExempt[to] ||
                        from == ds.owner ||
                        from == ds.router
                );
                _transfer(from, to, amount);
            }
        }
    }
    function _swapBack() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 swapBackAmount = ds.balanceOf[address(this)];
        if (swapBackAmount >= ds.swapBackMin) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = ds.wETH;
            IUniswapV2Router(ds.router)
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    swapBackAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
        }
    }
    function updateFees(
        uint256 newBuyFee,
        uint256 newSellFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newBuyFee <= 15);
        require(newSellFee <= 15);
        _swapBack();
        withdrawFees();
        ds.buyFee = newBuyFee > 0 ? newBuyFee : 1;
        ds.sellFee = newSellFee > 0 ? newSellFee : 1;
    }
    function withdrawFees() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amount = address(this).balance;
        if (amount > 0) {
            uint256 totalFee = ((ds.buyFee + ds.sellFee) * 10) / 2;
            if (totalFee == 10) {
                (bool success, ) = ds.utilReceiver.call{value: amount}("");
                require(success);
            } else {
                uint256 utilAmount = (amount * 10) / totalFee;
                (bool success, ) = ds.utilReceiver.call{value: utilAmount}("");
                require(success);
                (success, ) = ds.feeReceiver.call{value: amount - utilAmount}(
                    ""
                );
                require(success);
            }
        }
    }
    function _swap(
        address from,
        address to,
        uint256 feeAmount,
        uint256 toAmount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balanceOf[address(this)] += feeAmount;
        ds.balanceOf[to] += toAmount;
        emit Transfer(from, address(this), feeAmount);
        emit Transfer(from, to, toAmount);
    }
    function _preSwap(
        address from,
        address to,
        uint256 amount,
        uint256 fee
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 feeAmount = (amount * fee) / 100;
        uint256 toAmount = amount - feeAmount;
        require(
            ds.balanceOf[to] + toAmount <= ds.maxWallet || ds.limitExempt[to]
        );
        _swap(from, to, feeAmount, toAmount);
    }
    function _transfer(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
    function _isPair(address account) internal view returns (bool isPair) {
        if (account.code.length > 0) {
            (isPair, ) = account.staticcall(abi.encodeWithSelector(0x0dfe1681));
        }
    }
}
