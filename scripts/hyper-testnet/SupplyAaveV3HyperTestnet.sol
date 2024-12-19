// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {HyperTestnetReservesConfig} from 'src/deployments/configs/HyperTestnetReservesConfig.sol';

contract Default is DeployUtils, HyperTestnetReservesConfig, Script {
  using stdJson for string;

  function run() external {
    address[] memory tokens = new address[](2);

    tokens[0] = 0x6fDbAF3102eFC67ceE53EeFA4197BE36c8E1A094; // USDC
    tokens[1] = 0x2222C34A8dd4Ea29743bf8eC4fF165E059839782; // sUSDe

    uint256[] memory amounts = new uint256[](3);

    amounts[0] = 1000e6;
    amounts[1] = 1000e18;

    address[] memory recipients = new address[](1);

    recipients[0] = 0xE0157B2E81506f7710e62b331eb113B232e89efA;

    console.log('Aave V3 Last Testnet Token Fauceting');
    console.log('sender', msg.sender);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

    _faucetTokens(
       tokens,
       amounts,
       recipients 
    );

    _supplyPool(
        tokens,
        amounts,
        vm.envAddress('SENDER')
    );

    vm.stopBroadcast();
  }
}