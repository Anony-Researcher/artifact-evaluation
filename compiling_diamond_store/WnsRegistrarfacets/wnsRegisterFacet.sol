// File: wns-multichain/implementations/wns_addresses_impl.sol

pragma solidity 0.8.24;
import "./TestLib.sol";
contract wnsRegisterFacet is Computation, Signatures, WnsImpl {
    function wnsRegister(
        Register[] memory register,
        bytes[] memory sig
    ) public payable nonReentrant {
        bool[] memory success = _registerAll(register, sig);
        settlePayment(register, success);
    }
    function wnsRegisterWithShare(
        Register[] memory register,
        bytes[] memory sig
    ) public payable nonReentrant {
        bool[] memory success = _registerAll(register, sig);
        settlePaymentWithShare(register, success);
    }
    function upgradeTier(
        TierUpgrade[] memory tierUpgrade,
        bytes[] memory sig
    ) public payable nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isActive, "Upgradation must be active.");
        require(tierUpgrade.length == sig.length, "Invalid parameters");
        require(
            calculateCostTierUpgrade(tierUpgrade) <= msg.value,
            "Ether value is not correct."
        );

        for (uint256 i = 0; i < tierUpgrade.length; i++) {
            TierUpgrade memory currentTierUpgrade = tierUpgrade[i];
            bytes memory currentSig = sig[i];

            require(
                verifyTierUpgradeSignature(currentTierUpgrade, currentSig) ==
                    getWnsAddress("_wnsSigner"),
                "Not authorised"
            );
            require(
                currentTierUpgrade.expiration >= block.timestamp,
                "Expired credentials."
            );

            WnsErc721Interface wnsErc721 = WnsErc721Interface(
                getWnsAddress("_wnsErc721")
            );
            require(
                currentTierUpgrade.tokenId < wnsErc721.getNextTokenId(),
                "Token does not exist"
            );
            require(
                wnsErc721.ownerOf(currentTierUpgrade.tokenId) == msg.sender,
                "Token not owned by caller"
            );

            WnsRegistryInterface wnsRegistry = WnsRegistryInterface(
                getWnsAddress("_wnsRegistry")
            );
            wnsRegistry.upgradeTier(
                currentTierUpgrade.tokenId,
                currentTierUpgrade.tier
            );
        }

        payable(getWnsAddress("_wnsWallet")).transfer(address(this).balance);
    }
    function changeLengths(uint256 min, uint256 max) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minLength = min;
        ds.maxLength = max;
    }
    function withdraw(
        address to,
        uint256 amount
    ) public nonReentrant onlyOwner {
        require(amount <= address(this).balance);
        payable(to).transfer(amount);
    }
    function flipActiveState() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isActive = !ds.isActive;
    }
    function calculateCostTierUpgrade(
        TierUpgrade[] memory tierUpgrade
    ) internal pure returns (uint256) {
        uint256 cost;
        for (uint256 i = 0; i < tierUpgrade.length; i++) {
            cost = cost + tierUpgrade[i].cost;
        }
        return cost;
    }
    function _registerAll(
        Register[] memory register,
        bytes[] memory sig
    ) internal returns (bool[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isActive, "Registration must be active.");
        require(register.length == sig.length, "Invalid parameters.");
        require(
            calculateCost(register) <= msg.value,
            "Ether value is not correct."
        );

        bool[] memory success = new bool[](register.length);
        for (uint256 i = 0; i < register.length; i++) {
            success[i] = _register(register[i], sig[i]);
        }

        return success;
    }
    function calculateCost(
        Register[] memory register
    ) internal pure returns (uint256) {
        uint256 cost;
        for (uint256 i = 0; i < register.length; i++) {
            cost = cost + register[i].cost;
        }
        return cost;
    }
    function _register(
        Register memory register,
        bytes memory sig
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        WnsErc721Interface wnsErc721 = WnsErc721Interface(
            getWnsAddress("_wnsErc721")
        );
        require(
            verifySignature(register, sig) == getWnsAddress("_wnsSigner"),
            "Not authorized."
        );
        require(register.expiration >= block.timestamp, "Expired credentials.");
        require(register.ds.chainId == ds.chainId, "Invalid ds.chainId");

        string memory sanitizedName = sanitizeName(register.name);
        require(isLengthValid(sanitizedName), "Invalid name");

        bytes32 _hash = computeNamehash(sanitizedName);

        WnsRegistryInterface wnsRegistry = WnsRegistryInterface(
            getWnsAddress("_wnsRegistry")
        );
        if (wnsRegistry.getRecord(_hash) == 0) {
            wnsErc721.mintErc721(register.registrant);
            wnsRegistry.setRecord(
                _hash,
                wnsErc721.getNextTokenId(),
                string(abi.encodePacked(sanitizedName, register.extension)),
                register.tier
            );
            return true;
        } else {
            return false;
        }
    }
    function sanitizeName(
        string memory name
    ) public pure returns (string memory) {
        bytes memory nameBytes = bytes(name);

        uint dotPosition = nameBytes.length;
        for (uint i = 0; i < nameBytes.length; i++) {
            // Convert uppercase to lowercase
            if (uint8(nameBytes[i]) >= 65 && uint8(nameBytes[i]) <= 90) {
                nameBytes[i] = bytes1(uint8(nameBytes[i]) + 32);
            }
            // Check for the dot
            if (nameBytes[i] == bytes1(".")) {
                dotPosition = i;
                break;
            }
        }

        bytes memory sanitizedBytes = new bytes(dotPosition);
        for (uint i = 0; i < dotPosition; i++) {
            sanitizedBytes[i] = nameBytes[i];
        }

        return string(sanitizedBytes);
    }
    function isLengthValid(string memory name) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bytes memory nameBytes = bytes(name);
        uint length = nameBytes.length;

        return (length >= ds.minLength && length <= ds.maxLength);
    }
    function settlePaymentWithShare(
        Register[] memory registers,
        bool[] memory success
    ) internal {
        require(registers.length == success.length, "Mismatched array lengths");

        address[] memory shareAddresses = new address[](registers.length);
        uint256[] memory shareAmounts = new uint256[](registers.length);
        uint256 addressCount = 0;
        uint256 failedCost = 0;

        for (uint256 i = 0; i < registers.length; i++) {
            if (success[i]) {
                for (
                    uint256 j = 0;
                    j < registers[i].splitAddresses.length;
                    j++
                ) {
                    address payee = registers[i].splitAddresses[j];
                    uint256 amount = registers[i].splitAmounts[j];

                    bool addressFound = false;
                    for (uint256 k = 0; k < addressCount; k++) {
                        if (shareAddresses[k] == payee) {
                            shareAmounts[k] += amount;
                            addressFound = true;
                            break;
                        }
                    }

                    if (!addressFound) {
                        shareAddresses[addressCount] = payee;
                        shareAmounts[addressCount] = amount;
                        addressCount++;
                    }
                }
            } else {
                failedCost += registers[i].cost;
            }
        }

        for (uint256 i = 0; i < addressCount; i++) {
            payable(shareAddresses[i]).transfer(shareAmounts[i]);
        }

        if (failedCost > 0) {
            payable(msg.sender).transfer(failedCost);
        }

        payable(getWnsAddress("_wnsWallet")).transfer(address(this).balance);
    }
    function settlePayment(
        Register[] memory register,
        bool[] memory success
    ) internal {
        require(register.length == success.length, "Length doesn't match");

        uint256 failedCost = 0;
        for (uint256 i = 0; i < register.length; i++) {
            if (!success[i]) {
                failedCost += register[i].cost;
            }
        }

        if (failedCost > 0) {
            payable(msg.sender).transfer(failedCost);
        }

        payable(getWnsAddress("_wnsWallet")).transfer(address(this).balance);
    }
}
