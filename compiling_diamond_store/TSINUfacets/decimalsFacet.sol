/**
 *
 * $TSINU - TSUKA INU
 *
 *
 *
 * SOCIALS:
 *   TG | https://t.me/tsukainu
 *   Twitter |  https://twitter.com/tsukainu
 *   Website |  https://tsukainu.com
 *
 */
pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
