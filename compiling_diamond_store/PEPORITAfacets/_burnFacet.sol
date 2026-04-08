// SPDX-License-Identifier: MIT

// website https://peporita.fun/

//tg https://t.me/PeporitaErc20
pragma solidity ^0.8.7;
import "./TestLib.sol";
contract _burnFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function _burn(address _who, uint256 _value) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_value <= ds._rOwned[_who]);
        ds._rOwned[_who] = ds._rOwned[_who].sub(_value);
        ds._tTotal = ds._tTotal.sub(_value);
        emit Transfer(_who, address(0), _value);
    }
    function burn(uint256 _value) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds.devWallet);
        _burn(msg.sender, _value);
    }
}
