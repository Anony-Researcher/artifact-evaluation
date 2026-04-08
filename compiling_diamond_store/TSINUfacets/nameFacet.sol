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
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
