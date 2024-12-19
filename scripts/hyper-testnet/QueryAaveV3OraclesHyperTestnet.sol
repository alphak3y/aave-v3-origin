// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {HyperTestnetReservesConfig} from 'src/deployments/configs/HyperTestnetReservesConfig.sol';

import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';

contract Default is DeployUtils, HyperTestnetReservesConfig, Script {
  using stdJson for string;

  function run() external {
    address[] memory tokens = _fetchStableTokens();

    console.log('Aave V3 Hyper Testnet Add Pool Admin');
    console.log('sender', msg.sender);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

    // BTC
    MockAggregator(0x85C4F855Bc0609D2584405819EdAEa3aDAbfE97D).latestAnswer();
    MockAggregator(0x85C4F855Bc0609D2584405819EdAEa3aDAbfE97D).decimals();

    // ETH
    MockAggregator(0xBf3bA2b090188B40eF83145Be0e9F30C6ca63689).latestAnswer();
    MockAggregator(0xBf3bA2b090188B40eF83145Be0e9F30C6ca63689).decimals();

    // HYPE
    MockAggregator(0xC3346631E0A9720582fB9CAbdBEA22BC2F57741b).latestAnswer();
    MockAggregator(0xC3346631E0A9720582fB9CAbdBEA22BC2F57741b).decimals();

    // USDC
    MockAggregator(0xa0f2EF6ceC437a4e5F6127d6C51E1B0d3A746911).latestAnswer();
    MockAggregator(0xa0f2EF6ceC437a4e5F6127d6C51E1B0d3A746911).decimals();

    vm.stopBroadcast();
  }
}