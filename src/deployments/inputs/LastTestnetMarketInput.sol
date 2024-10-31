// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './MarketInput.sol';
import {WETH9} from 'src/contracts/dependencies/weth/WETH9.sol';
import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';

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

    config.networkBaseTokenPriceInUsdProxyAggregator = address(new MockAggregator(1800e8));
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = address(new MockAggregator(1e8));

    config.wrappedNativeToken = address(new WETH9());

    return (roles, config, flags, deployedContracts);
  }
}
