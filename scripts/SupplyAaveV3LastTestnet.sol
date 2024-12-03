// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import 'forge-std/StdJson.sol';
import 'forge-std/console.sol';

import {DeployUtils} from 'src/deployments/contracts/utilities/DeployUtils.sol';
import {LastTestnetReservesConfig} from 'src/deployments/configs/LastTestnetReservesConfig.sol';

contract Default is DeployUtils, LastTestnetReservesConfig, Script {
  using stdJson for string;

  function run() external {
    address[] memory tokens = new address[](3);

    tokens[0] = 0x7eA65834587ABF89A94d238a404C4A638Fc7641B; // WETH
    tokens[1] = 0x04f42e29D6057B7D70Ea1cab8E516C0029420B64; // USDC
    tokens[2] = 0xc9Fc065b2e986f29138Bd398E6FaAbd291c58B8E; // USDT

    uint256[] memory amounts = new uint256[](3);

    amounts[0] = 100e18;
    amounts[1] = 10000e6;
    amounts[2] = 10000e6;

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