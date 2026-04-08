// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is ERC20, IIpToken {
    using SafeERC20 for IERC20;

    modifier onlyTokenManager() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds._tokenManager,
            AmmErrors.CALLER_NOT_TOKEN_MANAGER
        );
        _;
    }

    function decimals() public view override returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
    function getAsset() external view override returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._asset;
    }
    function getTokenManager() external view override returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokenManager;
    }
    function setTokenManager(
        address newTokenManager
    ) external override onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newTokenManager != address(0), IporErrors.WRONG_ADDRESS);
        ds._tokenManager = newTokenManager;
        emit TokenManagerChanged(newTokenManager);
    }
    function mint(
        address account,
        uint256 amount
    ) external override onlyTokenManager {
        require(amount > 0, AmmPoolsErrors.IP_TOKEN_MINT_AMOUNT_TOO_LOW);
        _mint(account, amount);
        emit Mint(account, amount);
    }
    function burn(
        address account,
        uint256 amount
    ) external override onlyTokenManager {
        require(amount > 0, AmmPoolsErrors.IP_TOKEN_BURN_AMOUNT_TOO_LOW);
        _burn(account, amount);
        emit Burn(account, amount);
    }
}
