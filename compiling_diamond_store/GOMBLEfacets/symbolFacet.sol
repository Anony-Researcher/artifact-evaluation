/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://twitter.com/gomblegames
    // Twitter: https://twitter.com/gomblegames
    // Website: https://www.aethir.com/
    // Discord: https://discord.com/invite/gomblegames
    // Medium:  https://medium.com/@gomblegames
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
