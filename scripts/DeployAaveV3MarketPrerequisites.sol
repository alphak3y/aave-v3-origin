// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

contract DeployWrappedNativeToken {
  using stdJson for string;

  function run() external {
    MarketConfig memory config;

    console.log('Aave V3 Wrapped Native Token Deployment');
    console.log('sender', msg.sender);

    config.networkBaseTokenPriceInUsdProxyAggregator = address(new MockAggregator(1800e8));
    config.marketReferenceCurrencyPriceInUsdProxyAggregator = address(new MockAggregator(1e8));

    config.wrappedNativeToken = address(new WETH9());

    console.log('MARKET CONFIG:');
    console.log('--------------\n');
    console.log('WETH9:', config.wrappedNativeToken);
    console.log('WETH Mock Oracle:', config.networkBaseTokenPriceInUsdProxyAggregator);
    console.log('USD Mock Oracle:', config.marketReferenceCurrencyPriceInUsdProxyAggregator);
  }
}