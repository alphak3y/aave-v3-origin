// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import 'src/deployments/interfaces/IMarketReportTypes.sol';
import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {LastTestnetMarketInput} from '../src/deployments/inputs/LastTestnetMarketInput.sol';
import {CapAutomator} from 'src/contracts/dependencies/sparklend/CapAutomator.sol';

contract Default is DeployUtils, LastTestnetMarketInput, Script {
  using stdJson for string;

  function run() external {
    PostDeploymentConfig memory config;

    console.log('Aave V3 Cap Automator Deployment');
    console.log('sender', msg.sender);
    console.log('chainid', block.chainid);

    config = _getPostDeploymentConfig(msg.sender);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

    address capAutomator = address(new CapAutomator(config.poolAddressesProvider));

    vm.stopBroadcast();

    console.log('\nMARKET CONFIG:');
    console.log('--------------\n');
    console.log('CapAutomator:', capAutomator);
  }
}