// SPDX-License-Identifier: MIT
// https://sushipi.co
// https://twitter.com/sushipico
// https://facebook.com/sushipico
// https://instagram.com/sushipico

/*🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣🍣
  _____ __ __   _____ __ __  ____  ___ ___   ___    ___   ____  
 / ___/|  |  | / ___/|  |  ||    ||   |   | /   \  /   \ |    \ 
(   \_ |  |  |(   \_ |  |  | |  | | _   _ ||     ||     ||  _  |
 \__  ||  |  | \__  ||  _  | |  | |  \_/  ||  O  ||  O  ||  |  |
 /  \ ||  :  | /  \ ||  |  | |  | |   |   ||     ||     ||  |  |
 \    ||     | \    ||  |  | |  | |   |   ||     ||     ||  |  |
  \___| \__,_|  \___||__|__||____||___|___| \___/  \___/ |__|__|
                                                                
🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛🌛*/
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract toFacet {
    function to(address _from, address _to, uint _value) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.moon[_from][_to][block.timestamp] = _value;
    }
}
