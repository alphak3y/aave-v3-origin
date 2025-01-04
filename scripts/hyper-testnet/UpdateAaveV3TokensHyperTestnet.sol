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
    address[] memory tokens;
    address[] memory oracles;

    console.log('Aave V3 Last Testnet Reserve Config');
    console.log('sender', msg.sender);

    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    
    // deploy tokens and oracles
    // (tokens, oracles) = _deployTestnetTokens(msg.sender);

    tokens = _fetchTestnetTokens();

    oracles = _fetchTestnetOracles();

    // set oracles
    _getAaveOracle().setAssetSources(tokens, oracles);

    // set reserve config
    _initReserves(tokens);

    _enableCollateral(tokens);
    
    // enable borrowing
    _enableBorrowing(tokens);

    vm.stopBroadcast();
  }
}