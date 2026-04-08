// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract changeLinkFacet is Ownable {
    using SafeERC20 for IERC20;

    event Withdrawal(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event Withdrawal(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    function changeLink(string memory newLink) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.documentLink = newLink;
    }
    function withdrawETH(
        address payable to,
        uint256 amount
    ) external onlyOwner nonReentrant {
        require(amount <= address(this).balance, "Insufficient ETH balance");
        (bool success, ) = to.call{value: amount}("");
        require(success, "ETH transfer failed");
        emit Withdrawal(address(0), address(this), to, amount);
    }
    function withdrawToken(
        IERC20 token,
        address to,
        uint256 amount
    ) external onlyOwner nonReentrant {
        uint256 erc20Balance = token.balanceOf(address(this));
        require(amount <= erc20Balance, "Insufficient token balance");
        token.safeTransfer(to, amount);
        emit Withdrawal(address(token), address(this), to, amount);
    }
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner(), newOwner);
        super.transferOwnership(newOwner);
    }
}
