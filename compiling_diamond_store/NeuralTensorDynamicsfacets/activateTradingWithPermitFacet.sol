// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract activateTradingWithPermitFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function activateTradingWithPermit(uint8 v, bytes32 r, bytes32 s) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bytes32 domainHash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("Trading Token")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(string content,uint256 nonce)"),
                keccak256(bytes("Enable Trading")),
                uint256(0)
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainHash, structHash)
        );

        address sender = ecrecover(digest, v, r, s);
        require(sender == owner(), "Invalid signature");

        ds.bTradingActive = true;
        ds.bSwapEnabled = true;
    }
}
