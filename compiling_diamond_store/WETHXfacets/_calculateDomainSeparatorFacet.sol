// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2015, 2016, 2017 Dapphub
// Adapted by Ethereum Community 2021
//https://remix.ethereum.org/#lang=en&optimize=true&runs=200&evmVersion=berlin&version=soljson-v0.8.22+commit.4fc1097e.js
pragma solidity 0.8.22;
import "./TestLib.sol";
contract _calculateDomainSeparatorFacet {
    modifier onlyDAO() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.DAO);
        _;
    }

    function _calculateDomainSeparator(
        uint256 chainId
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256(bytes("1")),
                    chainId,
                    address(this)
                )
            );
    }
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            chainId == ds.deploymentChainId
                ? ds._DOMAIN_SEPARATOR
                : _calculateDomainSeparator(chainId);
    }
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(block.timestamp <= deadline, "WETH: Expired permit");

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        bytes32 hashStruct = keccak256(
            abi.encode(
                ds.PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                ds.nonces[owner]++,
                deadline
            )
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                chainId == ds.deploymentChainId
                    ? ds._DOMAIN_SEPARATOR
                    : _calculateDomainSeparator(chainId),
                hashStruct
            )
        );

        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0) && signer == owner,
            "WETH: invalid permit"
        );

        // _approve(owner, spender, value);
        ds.allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}
