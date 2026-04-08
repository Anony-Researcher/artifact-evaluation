// Sources flattened with hardhat v2.12.4 https://hardhat.org

// File contracts/utils/OpenseaDelegate.sol

// License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract funcBulkTransferFacet is ERC721Upgradeable {
    function funcBulkTransfer(address _pTo, uint256[] memory _pIds) external {
        require(_pIds.length > 0, "TIPSYEC_404");

        for (uint256 i = 0; i < _pIds.length; i++) {
            transferFrom(_msgSender(), _pTo, _pIds[i]);
        }
    }
}
