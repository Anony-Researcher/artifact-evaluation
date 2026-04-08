// SPDX-License-Identifier: MIT
/** 

Website: https://www.altvm.com/

AltVM is a token protocol designed to facilitate seamless interoperability among diverse Virtual Machines (VMs) 
within the blockchain ecosystem. Utilizing advanced cryptographic techniques and decentralized governance mechanisms, 
AltVM acts as a bridging protocol, enabling efficient communication and data exchange across disparate VM environments. 
By providing a standardized framework for inter-VM interactions, AltVM addresses the challenges of siloed VM ecosystems, 
promoting greater collaboration and synergy among blockchain platforms.

In the realm of decentralized computing, the proliferation of various Virtual Machines (VMs) has presented a significant challenge: 
the lack of interoperability between disparate platforms. Each blockchain network operates within its own VM environment, 
leading to isolated ecosystems with limited communication capabilities. Recognizing the need for a solution to bridge these divides, 
AltVM emerged as a pioneering token protocol.

Rooted in advanced cryptographic principles and decentralized governance, AltVM serves as a universal bridge connecting different VMs 
within the blockchain landscape. Through its protocol, AltVM establishes standardized communication channels and data exchange 
mechanisms, enabling seamless interoperability among diverse platforms.

The journey of AltVM is characterized by technical innovation and collaborative effort. Drawing upon expertise from cryptography, 
distributed systems, and blockchain technology, the development team behind AltVM meticulously crafted a protocol capable of 
transcending the boundaries of individual VM ecosystems.

As AltVM gains traction within the academic and technical communities, its impact on the blockchain ecosystem becomes increasingly 
evident. Through academic research, peer-reviewed publications, and collaborative partnerships with leading blockchain projects, 
AltVM continues to advance the frontier of interoperability, driving forward the evolution of decentralized technology.

With each new integration and protocol enhancement, AltVM moves closer to realizing its vision of a truly interconnected and 
interoperable blockchain ecosystem. As the academic and technical community rally behind the mission of AltVM, the future of 
decentralized computing appears brighter than ever before.

**/

pragma solidity 0.8.15;
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
