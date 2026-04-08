/**

CrowdDrive Airdrop Claimer

Website: https://cdrive.cx

Twitter: https://twitter.com/cdrive_eth

Telegram: https://t.me/cdriveportal

*/

//SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract depositTokensFacet {
    event TokenDeposited(address indexed depositor, uint256 amount);
    event Whitelisted();
    function depositTokens(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "Amount must be greater than 0");
        require(
            ds.token.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );
        emit TokenDeposited(msg.sender, amount);
    }
    function addToWhitelist(
        address[] memory accounts,
        uint256[] memory amounts
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            accounts.length == amounts.length,
            "Input arrays must have the same length"
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint256 amount = amounts[i];
            require(account != address(0), "Invalid address");
            require(amount > 0, "Claimable amount must be greater than 0");
            unchecked {
                ds.whitelist[account] = ds.whitelist[account] + amount; // Add to existing claimable amount
            }
        }
        emit Whitelisted();
    }
    function removeFromWhitelist(address[] memory accounts) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            ds.whitelist[account] = 0;
        }
    }
    function transferForeignToken(
        address _token,
        address _to
    ) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");

        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }
    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.token = IERC20(_tokenAddress);
    }
}
