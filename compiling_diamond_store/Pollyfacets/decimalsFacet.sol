/**

    //  https://t.me/PollyErc

    //  https://www.polly-official.com/

    //   https://twitter.com/Polly_ERC20

    //  https://medium.com/@pollyerc20/

    //  https://polly-the-frog.gitbook.io/polly-the-frog



// SPDX-License-Identifier: UNLICENSE

/*




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
