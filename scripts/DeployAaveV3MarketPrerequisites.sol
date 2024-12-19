// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import 'src/deployments/interfaces/IMarketReportTypes.sol';
import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {WHYPE} from 'src/contracts/dependencies/weth/WHYPE.sol';
import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';

contract Default is DeployUtils, Script {
  using stdJson for string;

  function run() external {
    MarketConfig memory config;

    console.log('Aave V3 Wrapped Native Token Deployment');
    console.log('sender', msg.sender);
    console.log('chainid', block.chainid);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

    config.networkBaseTokenPriceInUsdProxyAggregator = address(new MockAggregator(10e8));
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = address(new MockAggregator(1e8));

    config.wrappedNativeToken = address(new WHYPE());

    //TODO: check if SafeSingletonDeployer exists; if not deploy it

    vm.stopBroadcast();

    console.log('\nMARKET CONFIG:');
    console.log('--------------\n');
    console.log('WETH9:', config.wrappedNativeToken);
    console.log('WETH Mock Oracle:', config.networkBaseTokenPriceInUsdProxyAggregator);
    console.log('USD Mock Oracle:', config.marketReferenceCurrencyPriceInUsdProxyAggregator);
  }
}