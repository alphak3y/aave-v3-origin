// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './MarketInput.sol';
import {WETH9} from 'src/contracts/dependencies/weth/WETH9.sol';
import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';

import 'forge-std/console.sol';

contract LastTestnetMarketInput is MarketInput {
  function _getMarketInput(
    address deployer
  )
    internal
    override
    returns (
      Roles memory roles,
      MarketConfig memory config,
      DeployFlags memory flags,
      MarketReport memory deployedContracts
    )
  {
    roles.marketOwner = deployer;
    roles.emergencyAdmin = deployer;
    roles.poolAdmin = deployer;

    config.marketId = 'Aave V3 Last Testnet Market';
    config.providerId = 8080;
    config.oracleDecimals = 8;
    config.flashLoanPremiumTotal = 0.0005e4;
    config.flashLoanPremiumToProtocol = 0.0004e4;

    config.networkBaseTokenPriceInUsdProxyAggregator = 0xC5b8E1Ecef17a08eB5d09d331671a3DE14212D27;
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = 0x32375ea79aB576D473f2E4A26D907246baC4Cf80;

    config.wrappedNativeToken = 0xe69733aE7CA4bee8ffd5CCb9c78439Ba09fed4B3;

    console.log('wrapped native token', config.wrappedNativeToken);

    config.salt = keccak256(abi.encodePacked('cubish'));

    return (roles, config, flags, deployedContracts);
  }

  function _getPostDeploymentConfig(
    address deployer
  ) 
    internal
    returns (
      PostDeploymentConfig memory config
    )
  { 
    config.poolAddressesProvider = 0x270542372e5a73c39E4290291AB88e2901cCEF2D;
    
    return config;
  }
}
