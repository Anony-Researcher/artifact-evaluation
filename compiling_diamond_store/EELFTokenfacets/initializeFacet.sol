// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract initializeFacet is
    ERC165,
    ERC20VotesUpgradeable,
    ERC20Upgradeable,
    OwnableUpgradeable
{
    modifier onlyLimitedUser() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds._governer || msg.sender == ds._lockproxy,
            "This action can only be performed by limited user"
        );
        _;
    }

    event SetGoverner(address indexed owner, address indexed governer);
    event SetLockProxy(address indexed owner, address indexed lockproxy);
    function initialize(
        string memory mame,
        string memory symbol
    ) public initializer {
        __ERC20_init(mame, symbol);
        __Ownable_init_unchained();
    }
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC20).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function setGoverner(address _address) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._governer = _address;
        emit SetGoverner(owner(), _address);
    }
    function setLockProxy(address _address) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._lockproxy = _address;
        emit SetLockProxy(owner(), _address);
    }
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._afterTokenTransfer(from, to, amount);
    }
    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._mint(to, amount);
    }
    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._burn(account, amount);
    }
    function burnFrom(address account, uint256 amount) public onlyLimitedUser {
        _burn(account, amount);
    }
    function mint(address to, uint256 amount) public onlyLimitedUser {
        _mint(to, amount);
    }
}
