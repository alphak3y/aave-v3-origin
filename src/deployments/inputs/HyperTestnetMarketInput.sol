// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './MarketInput.sol';
import {WETH9} from 'src/contracts/dependencies/weth/WETH9.sol';
import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';

import 'forge-std/console.sol';

contract HyperTestnetMarketInput is MarketInput {
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

    config.marketId = 'Hypurr.fi Testnet Market';
    config.providerId = 8080;
    config.oracleDecimals = 8;
    config.flashLoanPremiumTotal = 0.0005e4;
    config.flashLoanPremiumToProtocol = 0.0004e4;

    config.networkBaseTokenPriceInUsdProxyAggregator = 0xCEdB7DF30332f003E177f732a4a04019e1909e85;
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = 0x3399453a0353E788dBEb7c892Add2aa913Cf4416;

    config.wrappedNativeToken = 0x8bf86549d308e50Db889cF843AEBd6b7B0d7BB9a;

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
