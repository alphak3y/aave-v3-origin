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

    config.networkBaseTokenPriceInUsdProxyAggregator = 0xe601e1da33d3ae495244671605eE521fEfbe46a1;
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = 0xCD4634e86b39a7378413025229A6faae4b096057;

    config.wrappedNativeToken = 0x76279060dA38EDbF86f1Dc35ee1fD6B1aE8a13F0;

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
    PostDeploymentConfig memory config;
    
    config.poolAddressesProvider = 0x5D9C960C804FD258CEd466cAcf6bBC5Ff7cb9381;
    
    return config;
  }
}
