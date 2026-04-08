// SPDX-License-Identifier: MIT

pragma solidity =0.8.9;
import "./TestLib.sol";
contract withdrawFacet {
    modifier onlyAdmin() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.admin_, "TA-4: auth failed");
        _;
    }

    function withdraw(
        address _token,
        address _recipient,
        uint256 _amount
    ) external onlyAdmin {
        require(
            IERC20(_token).transfer(_recipient, _amount),
            "TA-6: transfer failed"
        );
    }
}
