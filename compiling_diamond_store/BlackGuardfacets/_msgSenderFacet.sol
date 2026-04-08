// File: Ownable.sol

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
import "./TestLib.sol";
contract _msgSenderFacet is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        _transferFrom(_msgSender(), to, value);
        return true;
    }
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(sender != address(0), "Cannot transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool isExempt = ds._isFeeExempt[sender] || ds._isFeeExempt[recipient];
        uint256 gonAmount = amount.mul(ds._gonsPerFragment);

        if (!isExempt) {
            // Apply transaction limits and record trading data for non-exempt addresses
            _aTL(sender, recipient, amount);
        }

        ds._gonBalances[sender] = ds._gonBalances[sender].sub(gonAmount);
        ds._gonBalances[recipient] = ds._gonBalances[recipient].add(gonAmount);

        emit Transfer(sender, recipient, amount);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._allowedFragments[from][_msgSender()] != uint256(-1)) {
            ds._allowedFragments[from][_msgSender()] = ds
            ._allowedFragments[from][_msgSender()].sub(value);
        }
        _transferFrom(from, to, value);
        return true;
    }
    function _aTL(address sender, address recipient, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.TradeData storage data = ds.tradeData[sender];
        if (recipient == ds.pairAddress) {
            // Selling
            require(amount <= ds.mTA, "exceeds");
            uint256 timeSinceLastSale = block.timestamp - data.lastSaleTime;
            require(
                timeSinceLastSale > TWENTY_FOUR_HOURS ||
                    (data.saleAmount.add(amount) <=
                        ds._totalSupply.mul(ds.sLP).div(100)),
                "Sell limit reached"
            );
            if (timeSinceLastSale > TWENTY_FOUR_HOURS) {
                data.lastSaleTime = block.timestamp;
                data.saleAmount = amount;
            } else {
                data.saleAmount = data.saleAmount.add(amount);
            }
        } else if (sender == ds.pairAddress) {
            // Buying
            require(amount <= ds._totalSupply.mul(ds.bLP).div(100), "exceeds");
            uint256 timeSinceLastBuy = block.timestamp - data.lastBuyTime;
            require(
                timeSinceLastBuy > TWENTY_FOUR_HOURS ||
                    (data.buyAmount.add(amount) <=
                        ds._totalSupply.mul(ds.bLP).div(100)),
                "Buy limit reached"
            );
            if (timeSinceLastBuy > TWENTY_FOUR_HOURS) {
                data.lastBuyTime = block.timestamp;
                data.buyAmount = amount;
            } else {
                data.buyAmount = data.buyAmount.add(amount);
            }
        }
    }
    function approve(
        address spender,
        uint256 value
    ) public override returns (bool) {
        _approve(_msgSender(), spender, value);
        return true;
    }
    function _approve(address owner_, address spender, uint256 value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner_ != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        ds._allowedFragments[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowedFragments[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 oldValue = ds._allowedFragments[_msgSender()][spender];
        if (subtractedValue >= oldValue) {
            _approve(_msgSender(), spender, 0);
        } else {
            _approve(_msgSender(), spender, oldValue.sub(subtractedValue));
        }
        return true;
    }
}
