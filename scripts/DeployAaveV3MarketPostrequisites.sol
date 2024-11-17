// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import 'src/deployments/interfaces/IMarketReportTypes.sol';
import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {LastTestnetMarketInput} from '../src/deployments/inputs/LastTestnetMarketInput.sol';
import {CapAutomator} from 'src/contracts/dependencies/sparklend/CapAutomator.sol';
import {WrappedTokenGatewayV3} from 'src/contracts/helpers/WrappedTokenGatewayV3.sol';
import {IPool} from 'src/contracts/interfaces/IPool.sol';

contract Default is DeployUtils, LastTestnetMarketInput, Script {
  using stdJson for string;

  function run() external {
    PostDeploymentConfig memory config;

    console.log('Aave V3 Cap Automator Deployment');
    console.log('sender', msg.sender);
    console.log('chainid', block.chainid);

    config = _getPostDeploymentConfig(msg.sender);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

    // address capAutomator = address(new CapAutomator(config.poolAddressesProvider));
    new WrappedTokenGatewayV3(0x1A86bA62361DDCc680b2B230c7b3CcF5D777ed7E, 0xE0157B2E81506f7710e62b331eb113B232e89efA,IPool(0xBD2f32C02140641f497B0Db7B365122214f7c548));

    vm.stopBroadcast();

    // console.log('\nMARKET CONFIG:');
    // console.log('--------------\n');
    // console.log('CapAutomator:', capAutomator);
  }
}