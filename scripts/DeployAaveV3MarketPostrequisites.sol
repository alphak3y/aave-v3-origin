// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import 'src/deployments/interfaces/IMarketReportTypes.sol';
import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {CapAutomator} from 'src/contracts/dependencies/sparklend/CapAutomator.sol';
import {WrappedTokenGatewayV3} from 'src/contracts/helpers/WrappedTokenGatewayV3.sol';
import {IPool} from 'src/contracts/interfaces/IPool.sol';

contract Default is DeployUtils, Script {
  using stdJson for string;

  function run() external {
    console.log('Aave V3 Cap Automator Deployment');
    console.log('sender', msg.sender);
    console.log('chainid', block.chainid);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

    // address capAutomator = address(new CapAutomator(0x7d01f1BA6fAcF734649e9589670DB16F9172Be2C));

    CapAutomator(0x14b22fE50ac34Eb6F5D4a653926a26636b5cB990).supplyCapConfigs(0x6fDbAF3102eFC67ceE53EeFA4197BE36c8E1A094);
    
    vm.stopBroadcast();

    console.log('\nMARKET CONFIG:');
    console.log('--------------\n');
    // console.log('CapAutomator:', capAutomator);
  }
}