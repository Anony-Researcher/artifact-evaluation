// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2015, 2016, 2017 Dapphub
// Adapted by Ethereum Community 2021
//https://remix.ethereum.org/#lang=en&optimize=true&runs=200&evmVersion=berlin&version=soljson-v0.8.22+commit.4fc1097e.js
pragma solidity 0.8.22;
import "./TestLib.sol";
contract depositFacet is IWETHX {
    modifier onlyDAO() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.DAO);
        _;
    }

    function deposit() external payable override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // _mintTo(msg.sender, msg.value);
        require(ds.isNativeTokenEther, "WETH: native token have to be ETH");
        if (ds.MNPAddress != address(0)) {
            (bool result, ) = ds.MNPAddress.call{value: msg.value}("");
            require(result);
        }
        ds.balanceOf[msg.sender] += msg.value;
        emit Transfer(address(0), msg.sender, msg.value);
    }
    function depositTo(address to) external payable override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isNativeTokenEther, "WETH: native token have to be ETH");
        if (ds.MNPAddress != address(0)) {
            (bool result, ) = ds.MNPAddress.call{value: msg.value}("");
            require(result);
        }
        ds.balanceOf[to] += msg.value;
        emit Transfer(address(0), to, msg.value);
    }
    function swapFromTicket(uint256 value) external override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.MNPAddress != address(0)) {
            require(
                IERC20(ds.ticket).transferFrom(
                    msg.sender,
                    ds.MNPAddress,
                    value
                ),
                "Transfer of ds.ticket failed"
            );
        } else {
            require(
                IERC20(ds.ticket).transferFrom(
                    msg.sender,
                    address(this),
                    value
                ),
                "Transfer of tocket failed"
            );
        }
        ds.balanceOf[msg.sender] += value;
        emit Transfer(address(0), msg.sender, value);
    }
    function swapToTicket(uint256 value) external override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.MNPAddress != address(0)) {
            require(
                IERC20(ds.ticket).transferFrom(
                    ds.MNPAddress,
                    msg.sender,
                    value
                ),
                "Transfer of ds.ticket failed"
            );
        } else {
            require(
                IERC20(ds.ticket).transferFrom(
                    address(this),
                    msg.sender,
                    value
                ),
                "Transfer of ds.ticket failed"
            );
        }
        ds.balanceOf[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
    }
    function depositToAndCall(
        address to,
        bytes calldata data
    ) external payable override returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isNativeTokenEther, "WETH: native token have to be ETH");
        if (ds.MNPAddress != address(0)) {
            (bool result, ) = ds.MNPAddress.call{value: msg.value}("");
            require(result);
        }
        ds.balanceOf[to] += msg.value;
        emit Transfer(address(0), to, msg.value);

        return
            ITransferReceiver(to).onTokenTransfer(msg.sender, msg.value, data);
    }
    function withdraw(uint256 value) external override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // _burnFrom(msg.sender, value);
        uint256 balance = ds.balanceOf[msg.sender];
        require(balance >= value, "WETH: burn amount exceeds balance");
        ds.balanceOf[msg.sender] = balance - value;
        emit Transfer(msg.sender, address(0), value);
        if (ds.MNPAddress != address(0)) {
            bool result = IMNPool(ds.MNPAddress).transfer(msg.sender, value);
            require(result);
        } else {
            // _transferEther(msg.sender, value);
            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }
    }
    function withdrawTo(address payable to, uint256 value) external override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // _burnFrom(msg.sender, value);
        uint256 balance = ds.balanceOf[msg.sender];
        require(balance >= value, "WETH: burn amount exceeds balance");
        ds.balanceOf[msg.sender] = balance - value;
        emit Transfer(msg.sender, address(0), value);

        if (ds.MNPAddress != address(0)) {
            bool result = IMNPool(ds.MNPAddress).transfer(to, value);
            require(result);
        } else {
            // _transferEther(to, value);
            (bool success, ) = to.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }
    }
    function withdrawFrom(
        address from,
        address payable to,
        uint256 value
    ) external override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (from != msg.sender) {
            // _decreaseAllowance(from, msg.sender, value);
            uint256 allowed = ds.allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "WETH: request exceeds ds.allowance");
                uint256 reduced = allowed - value;
                ds.allowance[from][msg.sender] = reduced;
                emit Approval(from, msg.sender, reduced);
            }
        }

        // _burnFrom(from, value);
        uint256 balance = ds.balanceOf[from];
        require(balance >= value, "WETH: burn amount exceeds balance");
        ds.balanceOf[from] = balance - value;
        emit Transfer(from, address(0), value);

        if (ds.MNPAddress != address(0)) {
            bool result = IMNPool(ds.MNPAddress).transfer(to, value);
            require(result);
        } else {
            // _transferEther(to, value);
            (bool success, ) = to.call{value: value}("");
            require(success, "WETH: Ether transfer failed");
        }
    }
    function approveAndCall(
        address spender,
        uint256 value,
        bytes calldata data
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // _approve(msg.sender, spender, value);
        ds.allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return
            IApprovalReceiver(spender).onTokenApproval(msg.sender, value, data);
    }
    function transferAndCall(
        address to,
        uint value,
        bytes calldata data
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // _transferFrom(msg.sender, to, value);
        if (to != address(0)) {
            // Transfer
            uint256 balance = ds.balanceOf[msg.sender];
            require(balance >= value, "WETH: transfer amount exceeds balance");

            ds.balanceOf[msg.sender] = balance - value;
            ds.balanceOf[to] += value;
            emit Transfer(msg.sender, to, value);
        } else {
            // Withdraw
            uint256 balance = ds.balanceOf[msg.sender];
            require(balance >= value, "WETH: burn amount exceeds balance");
            ds.balanceOf[msg.sender] = balance - value;
            emit Transfer(msg.sender, address(0), value);

            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }

        return ITransferReceiver(to).onTokenTransfer(msg.sender, value, data);
    }
    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // _transferFrom(msg.sender, to, value);
        if (to != address(0) && to != address(this)) {
            // Transfer
            uint256 balance = ds.balanceOf[msg.sender];
            require(balance >= value, "WETH: transfer amount exceeds balance");

            ds.balanceOf[msg.sender] = balance - value;
            ds.balanceOf[to] += value;
            emit Transfer(msg.sender, to, value);
        } else {
            // Withdraw
            uint256 balance = ds.balanceOf[msg.sender];
            require(balance >= value, "WETH: burn amount exceeds balance");
            ds.balanceOf[msg.sender] = balance - value;
            emit Transfer(msg.sender, address(0), value);

            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }

        return true;
    }
    function withdrawUselessToken(
        address tokenAddress,
        uint256 amount
    ) public onlyDAO {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20 token = IERC20(tokenAddress);
        require(
            token.ds.balanceOf(address(this)) >= amount,
            "Insufficient token balance"
        );
        token.transfer(ds.DAO, amount);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (from != msg.sender) {
            // _decreaseAllowance(from, msg.sender, value);
            uint256 allowed = ds.allowance[from][msg.sender];
            if (allowed != type(uint256).max) {
                require(allowed >= value, "WETH: request exceeds ds.allowance");
                uint256 reduced = allowed - value;
                ds.allowance[from][msg.sender] = reduced;
                emit Approval(from, msg.sender, reduced);
            }
        }

        // _transferFrom(from, to, value);
        if (to != address(0) && to != address(this)) {
            // Transfer
            uint256 balance = ds.balanceOf[from];
            require(balance >= value, "WETH: transfer amount exceeds balance");

            ds.balanceOf[from] = balance - value;
            ds.balanceOf[to] += value;
            emit Transfer(from, to, value);
        } else {
            // Withdraw
            uint256 balance = ds.balanceOf[from];
            require(balance >= value, "WETH: burn amount exceeds balance");
            ds.balanceOf[from] = balance - value;
            emit Transfer(from, address(0), value);

            (bool success, ) = msg.sender.call{value: value}("");
            require(success, "WETH: ETH transfer failed");
        }

        return true;
    }
}
