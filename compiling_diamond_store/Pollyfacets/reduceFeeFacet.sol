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
contract reduceFeeFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function reduceFee(uint256 _newFee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
}
