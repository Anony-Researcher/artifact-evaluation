// SPDX-License-Identifier: MIT

/*

Fee receiver for all utilities deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/

*/

pragma solidity 0.8.25;

interface IToken {
    function transfer(address to, uint256 amount) external;
}

contract UtilReceiver {
    address private immutable utilRecovery;
    mapping(address => bool) public team;

    modifier onlyTeam {
        require(team[msg.sender] || msg.sender == utilRecovery);
        _;
    }

    constructor() {
        utilRecovery = 0x00009e07C5B40d75C5EBBC0aaa711105AE290000;
        team[0xBA647f817cD488a99BDb7BDed6a59FE78490fBAD] = true;
    }

    receive() external payable {
        require(msg.value > 0);
    }

    function depositETH() external payable {
        require(msg.value > 0);
    }

    function updateTeam(address account, bool status) external onlyTeam {
        team[account] = status;
    }

    function withdrawETH(address to, uint256 amount) external onlyTeam {
        (bool success,) = to.call{value: amount}("");
        require(success);
    }

    function withdrawToken(address token, address to, uint256 amount) external onlyTeam {
        IToken(token).transfer(to, amount);
    }
}