// SPDX-License-Identifier: MIT

//Pirateflix: Your all-in-one entertainment platform, uniting Movies, Series, Live Sports & Gaming effortlessly. Safeguarded by our exclusive VPN service for the ultimate viewing experience.

// Website:    https://pirateflix.app/
// Github:     https://github.com/pirateflix-official    <---- We encourage other devs to contribute !:)
// Docs:       https://docs.pirateflix.app/
// Twitter(X): https://x.com/pirateflix_app
// Youtube:    https://youtube.com/@Pirateflix-app
// TG Portal:  https://t.me/pirateflixportal
// VPN:        https://piratevpn.app

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
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
