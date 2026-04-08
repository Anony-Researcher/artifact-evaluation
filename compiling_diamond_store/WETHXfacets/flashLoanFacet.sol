// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2015, 2016, 2017 Dapphub
// Adapted by Ethereum Community 2021
//https://remix.ethereum.org/#lang=en&optimize=true&runs=200&evmVersion=berlin&version=soljson-v0.8.22+commit.4fc1097e.js
pragma solidity 0.8.22;
import "./TestLib.sol";
contract flashLoanFacet {
    modifier onlyDAO() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.DAO);
        _;
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 value,
        bytes calldata data
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(token == address(this), "WETH: flash mint only WETH10");
        require(
            value <= type(uint112).max,
            "WETH: individual loan limit exceeded"
        );
        ds.flashMinted = ds.flashMinted + value;
        require(
            ds.flashMinted <= type(uint112).max,
            "WETH: total loan limit exceeded"
        );

        // _mintTo(address(receiver), value);
        ds.balanceOf[address(receiver)] += value;
        emit Transfer(address(0), address(receiver), value);

        require(
            receiver.onFlashLoan(msg.sender, address(this), value, 0, data) ==
                ds.CALLBACK_SUCCESS,
            "WETH: flash loan failed"
        );

        // _decreaseAllowance(address(receiver), address(this), value);
        uint256 allowed = ds.allowance[address(receiver)][address(this)];
        if (allowed != type(uint256).max) {
            require(allowed >= value, "WETH: request exceeds ds.allowance");
            uint256 reduced = allowed - value;
            ds.allowance[address(receiver)][address(this)] = reduced;
            emit Approval(address(receiver), address(this), reduced);
        }

        // _burnFrom(address(receiver), value);
        uint256 balance = ds.balanceOf[address(receiver)];
        require(balance >= value, "WETH: burn amount exceeds balance");
        ds.balanceOf[address(receiver)] = balance - value;
        emit Transfer(address(receiver), address(0), value);

        ds.flashMinted = ds.flashMinted - value;
        return true;
    }
}
