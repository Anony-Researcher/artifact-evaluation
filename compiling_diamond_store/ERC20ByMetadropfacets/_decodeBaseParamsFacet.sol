//
//          Telegram (not verified): https://t.me/Pepe2ERC20
//          Website  (not verified): https://pepe2eth.vip
//
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@                                                                                                @@
// @@   This token was launched using software provided by Metadrop. To learn more or to launch      @@
// @@   your own token, visit: https://metadrop.com. See legal info at the end of this file.         @@
// @@                                                                                                @@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//
// SPDX-License-Identifier: BUSL-1.1
// Metadrop Contracts (v2.1.0)
//

// Sources flattened with hardhat v2.17.2 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _decodeBaseParamsFacet is Context, Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using SafeERC20 for IERC20;

    modifier onlyOwnerFactoryOrPool() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.metadropFactory != _msgSender() &&
            owner() != _msgSender() &&
            ds.driPool != _msgSender()
        ) {
            _revert(CallerIsNotFactoryProjectOwnerOrPool.selector);
        }
        if (owner() == _msgSender() && ds.driPool != address(0)) {
            _revert(CannotManuallyFundLPWhenUsingADRIPool.selector);
        }

        _;
    }
    modifier notDuringAutoswap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._autoSwapInProgress) {
            _revert(CannotPerformDuringAutoswap.selector);
        }
        _;
    }

    function _decodeBaseParams(
        address projectOwner_,
        bytes memory encodedBaseParams_
    ) internal returns (address[] memory recipients, uint256[] memory amounts) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transferOwnership(projectOwner_);
        bytes memory distribution;
        (ds._name, ds._symbol, , , distribution) = abi.decode(
            encodedBaseParams_,
            (string, string, bool, bool, bytes)
        );
        return abi.decode(distribution, (address[], uint256[]));
    }
}
