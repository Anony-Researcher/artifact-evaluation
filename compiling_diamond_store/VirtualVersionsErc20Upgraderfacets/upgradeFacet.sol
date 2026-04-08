// SPDX-License-Identifier: MIT

pragma solidity =0.8.9;
import "./TestLib.sol";
contract upgradeFacet {
    modifier onlyAdmin() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.admin_, "TA-4: auth failed");
        _;
    }

    function upgrade(address _recipient, uint256 _amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount != 0, "TA-2: zero token amount");
        require(_recipient != address(0), "TA-3: zero recipient address");

        require(
            IERC20(ds.oldToken_).transferFrom(
                msg.sender,
                BLACK_HOLE_ADDRESS,
                _amount
            ),
            "TA-7: burn failed"
        );
        require(
            IERC20(ds.newToken_).transfer(_recipient, _amount),
            "TA-8: transfer failed"
        );
    }
}
