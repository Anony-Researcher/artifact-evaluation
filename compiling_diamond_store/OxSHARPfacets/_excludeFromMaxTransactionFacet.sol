/**⠀⠀⠀⠀⠀⠀

X# is an open source development language for .NET, based on the xBase language. 
It comes in different flavours, such as Core, Visual Objects, Vulcan.NET, xBase++, Harbour, Foxpro and more. 
X# has been built on top of Roslyn, the open source architecture behind the current Microsoft C# and Microsoft Visual Basic compilers.

/////   GitHub: https://github.com/X-Sharp
/////   If you're interested to participate in beta, please email: robert@xsharp.eu

/////   Website: https://www.xsharp.eu/
/////   Twitter: https://twitter.com/xbasenet
/////   Facebook: https://www.facebook.com/xBaseNet/
/////   LinkedIn: https://www.linkedin.com/company/10207694
/////   YouTube: https://www.youtube.com/channel/UCFqLBMKPPxlN24xRxFGLiVA

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract _excludeFromMaxTransactionFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockSwapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function _excludeFromMaxTransaction(
        address account,
        bool excluded
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[account] = excluded;
    }
}
