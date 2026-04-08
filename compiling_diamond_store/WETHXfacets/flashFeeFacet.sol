// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2015, 2016, 2017 Dapphub
// Adapted by Ethereum Community 2021
//https://remix.ethereum.org/#lang=en&optimize=true&runs=200&evmVersion=berlin&version=soljson-v0.8.22+commit.4fc1097e.js
pragma solidity 0.8.22;
import "./TestLib.sol";
contract flashFeeFacet {
    modifier onlyDAO() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.DAO);
        _;
    }

    function flashFee(
        address token,
        uint256
    ) external view override returns (uint256) {
        require(token == address(this), "WETH: flash mint only WETH10");
        return 0;
    }
}
