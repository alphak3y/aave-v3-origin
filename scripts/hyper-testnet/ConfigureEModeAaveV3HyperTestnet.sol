// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {HyperTestnetReservesConfig} from 'src/deployments/configs/HyperTestnetReservesConfig.sol';

import {UiPoolDataProviderV3,IPoolAddressesProvider} from 'src/contracts/helpers/UiPoolDataProviderV3.sol';

contract Default is DeployUtils, HyperTestnetReservesConfig, Script {
  using stdJson for string;

  function run() external {
    address[] memory tokens = _fetchStableTokens();

    console.log('Aave V3 Hyper Testnet Add Pool Admin');
    console.log('sender', msg.sender);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

    _setupEModeGroup(
        1, // category id
        'Stablecoins Low Vol', // category label
        tokens, // collateral tokens
        tokens, // borrow tokens
        90_00, // 90% LTV
        92_00, // 92% Liq. threshold
        100_50 // 0.5% Liq. bonus
    );

    vm.stopBroadcast();
  }
}