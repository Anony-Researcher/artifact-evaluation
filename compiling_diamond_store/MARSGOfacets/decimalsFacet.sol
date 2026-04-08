/**   


            ╭━╮╭━╮╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭━━━━╮╱╭╮
            ┃┃╰╯┃┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱┃╭╮╭╮┃╱┃┃
            ┃╭╮╭╮┣━━┳━┳━━┳━━┳━━╮╰╯┃┃┣┻━┫┃╭┳━━┳━╮
            ┃┃┃┃┃┃╭╮┃╭┫━━┫╭╮┃╭╮┃╱╱┃┃┃╭╮┃╰╯┫┃━┫╭╮╮
            ┃┃┃┃┃┃╭╮┃┃┣━━┃╰╯┃╰╯┃╱╱┃┃┃╰╯┃╭╮┫┃━┫┃┃┃
            ╰╯╰╯╰┻╯╰┻╯╰━━┻━╮┣━━╯╱╱╰╯╰━━┻╯╰┻━━┻╯╰╯
            ╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃
            ╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯

            WEBSITE: https://marsgo.online/
            TWITTER: https://twitter.com/MARSGOTOKEN
            TG: https://t.me/marsgoportal


*/

pragma solidity ^0.8.24;
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
