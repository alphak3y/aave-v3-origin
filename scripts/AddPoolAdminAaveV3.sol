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
    address[] memory tokens;
    address[] memory oracles;

    console.log('Aave V3 Hyper Testnet Add Pool Admin');
    console.log('sender', msg.sender);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    
    // _addPoolAdmin(0x9FFd576173784375183100B17CCCAbC6C1150dC0);
    UiPoolDataProviderV3(0x108D9de78e1cC851531813A38ec0520d6A900198).getReservesData(IPoolAddressesProvider(0x7d01f1BA6fAcF734649e9589670DB16F9172Be2C));
    
    vm.stopBroadcast();
  }
}