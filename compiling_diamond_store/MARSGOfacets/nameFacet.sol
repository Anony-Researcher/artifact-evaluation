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
