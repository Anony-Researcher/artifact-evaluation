//   _____ ______ ______ _  __           _____
//  / ____|  ____|  ____| |/ /     /\   |_   _|
// | (___ | |__  | |__  | ' /     /  \    | |
//  \___ \|  __| |  __| |  <     / /\ \   | |
//  ____) | |____| |____| . \   / ____ \ _| |_
// |_____/|______|______|_|\_\ /_/    \_\_____|

// Telegram: t.me/seekaiportal
// Website: seekai.online
// X: x.com/seekaierc
// Docs: https://seekai.gitbook.io/seek-ai/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
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
