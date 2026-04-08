/*
    
    /$$      /$$  /$$$$$$  /$$$$$$$   /$$$$$$ 
    | $$$    /$$$ /$$__  $$| $$__  $$ /$$__  $$
    | $$$$  /$$$$| $$  \ $$| $$  \ $$| $$  \__/
    | $$ $$/$$ $$| $$  | $$| $$$$$$$/| $$      
    | $$  $$$| $$| $$  | $$| $$__  $$| $$      
    | $$\  $ | $$| $$  | $$| $$  \ $$| $$    $$
    | $$ \/  | $$|  $$$$$$/| $$  | $$|  $$$$$$/
    |__/     |__/ \______/ |__/  |__/ \______/ 
                                           
                                           
    Morc make animations and digital tools.
    We help teams to explain, deliver and disseminate their research.
    We specialise in providing a range of well thought out, creative digital products for clinical trials.

    Website: https://morph.co.uk/
    Twitter: https://twitter.com/morphhq
    Facebook: https://facebook.com/morphhq
    Youtube: https://youtube.com/channelmorph
    Linkedin: https://www.linkedin.com/company/morph-films/
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract burnFromFacet is ERC20, Ownable {
    function burnFrom(address account, uint256 amount) external {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}
