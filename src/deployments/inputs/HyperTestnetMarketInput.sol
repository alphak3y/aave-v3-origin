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

    config.marketId = 'Aave V3 Hyper Testnet Market';
    config.providerId = 8080;
    config.oracleDecimals = 8;
    config.flashLoanPremiumTotal = 0.0005e4;
    config.flashLoanPremiumToProtocol = 0.0004e4;

    config.networkBaseTokenPriceInUsdProxyAggregator = 0xB63E7eF70Ebdf52138Ec7A34f0C18019B51E7Ab6;
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = 0x364A07Cb81Cb744C2b1AfC624061B5308cD93699;

    config.wrappedNativeToken = 0x1B42442F2bDd70d581D0689342E315e699d36768;

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
