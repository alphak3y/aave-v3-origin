// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {AaveV3TokensBatch} from './batches/AaveV3TokensBatch.sol';
import {AaveV3PoolBatch} from './batches/AaveV3PoolBatch.sol';
import {AaveV3L2PoolBatch} from './batches/AaveV3L2PoolBatch.sol';
import {AaveV3GettersBatchOne} from './batches/AaveV3GettersBatchOne.sol';
import {AaveV3GettersBatchTwo} from './batches/AaveV3GettersBatchTwo.sol';
import {AaveV3GettersProcedureTwo} from '../../contracts/procedures/AaveV3GettersProcedureTwo.sol';
import {AaveV3PeripheryBatch} from './batches/AaveV3PeripheryBatch.sol';
import {AaveV3ParaswapBatch} from './batches/AaveV3ParaswapBatch.sol';
import {AaveV3SetupBatch} from './batches/AaveV3SetupBatch.sol';
import {AaveV3HelpersBatchOne} from './batches/AaveV3HelpersBatchOne.sol';
import {AaveV3HelpersBatchTwo} from './batches/AaveV3HelpersBatchTwo.sol';
import {AaveV3MiscBatch} from './batches/AaveV3MiscBatch.sol';
import '../../interfaces/IMarketReportTypes.sol';
import {IMarketReportStorage} from '../../interfaces/IMarketReportStorage.sol';
import {IPoolReport} from '../../interfaces/IPoolReport.sol';

/**
 * @title AaveV3BatchOrchestration
 * @author BGD
 * @dev Library which ensemble the deployment of Aave V3 using batch constructor deployment pattern.
 */
library AaveV3BatchOrchestration {
  function deployAaveV3(
    address deployer,
    Roles memory roles,
    MarketConfig memory config,
    DeployFlags memory flags,
    MarketReport memory deployedContracts
  ) internal returns (MarketReport memory) {
    (AaveV3SetupBatch setupBatch, InitialReport memory initialReport) = _deploySetupContract(
      deployer,
      roles,
      config,
      deployedContracts
    );

    AaveV3GettersBatchOne.GettersReportBatchOne memory gettersReport1 = _deployGettersBatch1(
      initialReport.poolAddressesProvider,
      config.networkBaseTokenPriceInUsdProxyAggregator,
      config.marketReferenceCurrencyPriceInUsdProxyAggregator
    );

    PoolReport memory poolReport = _deployPoolImplementations(
      initialReport.poolAddressesProvider,
      flags
    );

    PeripheryReport memory peripheryReport = _deployPeripherals(
      roles,
      config,
      initialReport.poolAddressesProvider,
      address(setupBatch)
    );

    MiscReport memory miscReport = _deployMisc(
      flags.l2,
      initialReport.poolAddressesProvider,
      config.l2SequencerUptimeFeed,
      config.l2PriceOracleSentinelGracePeriod
    );

    SetupReport memory setupReport = setupBatch.setupAaveV3Market(
      roles,
      config,
      poolReport.poolImplementation,
      poolReport.poolConfiguratorImplementation,
      gettersReport1.protocolDataProvider,
      peripheryReport.aaveOracle,
      peripheryReport.rewardsControllerImplementation,
      miscReport.priceOracleSentinel
    );

    ParaswapReport memory paraswapReport = _deployParaswapAdapters(
      roles,
      config,
      initialReport.poolAddressesProvider,
      peripheryReport.treasury
    );

    AaveV3GettersBatchTwo.GettersReportBatchTwo memory gettersReport2 = _deployGettersBatch2(
      setupReport.poolProxy,
      roles.poolAdmin,
      config.wrappedNativeToken,
      flags.l2
    );

    AaveV3TokensBatch.TokensReport memory tokensReport = _deployTokens(setupReport.poolProxy);

    ConfigEngineReport memory configEngineReport = _deployHelpersBatch1(
      setupReport,
      miscReport,
      peripheryReport,
      tokensReport
    );

    StaticATokenReport memory staticATokenReport = _deployHelpersBatch2(
      setupReport.poolProxy,
      setupReport.rewardsControllerProxy,
      peripheryReport.proxyAdmin
    );

    // Save final report at AaveV3SetupBatch contract
    MarketReport memory report = _generateMarketReport(
      initialReport,
      gettersReport1,
      gettersReport2,
      poolReport,
      peripheryReport,
      miscReport,
      paraswapReport,
      setupReport,
      tokensReport,
      configEngineReport,
      staticATokenReport
    );
    setupBatch.setMarketReport(report);

    return report;
  }

  function _deploySetupContract(
    address deployer,
    Roles memory roles,
    MarketConfig memory config,
    MarketReport memory deployedContracts
  ) internal returns (AaveV3SetupBatch, InitialReport memory) {
    AaveV3SetupBatch setupBatch = new AaveV3SetupBatch(deployer, roles, config, deployedContracts);
    return (setupBatch, setupBatch.getInitialReport());
  }

  function _deployGettersBatch1(
    address poolAddressesProvider,
    address networkBaseTokenPriceInUsdProxyAggregator,
    address marketReferenceCurrencyPriceInUsdProxyAggregator
  ) internal returns (AaveV3GettersBatchOne.GettersReportBatchOne memory) {
    AaveV3GettersBatchOne gettersBatch1 = new AaveV3GettersBatchOne(
      poolAddressesProvider,
      networkBaseTokenPriceInUsdProxyAggregator,
      marketReferenceCurrencyPriceInUsdProxyAggregator
    );

    return gettersBatch1.getGettersReportOne();
  }

  function _deployGettersBatch2(
    address poolProxy,
    address poolAdmin,
    address wrappedNativeToken,
    bool l2Flag
  ) internal returns (AaveV3GettersBatchTwo.GettersReportBatchTwo memory) {
    AaveV3GettersBatchTwo gettersBatch2;
    if (wrappedNativeToken != address(0) || l2Flag) {
      gettersBatch2 = new AaveV3GettersBatchTwo(poolProxy, poolAdmin, wrappedNativeToken, l2Flag);
      return gettersBatch2.getGettersReportTwo();
    }

    return
      AaveV3GettersProcedureTwo.GettersReportBatchTwo({
        wrappedTokenGateway: address(0),
        l2Encoder: address(0)
      });
  }

  function _deployHelpersBatch1(
    SetupReport memory setupReport,
    MiscReport memory miscReport,
    PeripheryReport memory peripheryReport,
    AaveV3TokensBatch.TokensReport memory tokensReport
  ) internal returns (ConfigEngineReport memory) {
    address treasury = peripheryReport.treasury;
    if (peripheryReport.revenueSplitter != address(0)) {
      treasury = peripheryReport.revenueSplitter;
    }

    AaveV3HelpersBatchOne helpersBatchOne = new AaveV3HelpersBatchOne(
      setupReport.poolProxy,
      setupReport.poolConfiguratorProxy,
      miscReport.defaultInterestRateStrategy,
      peripheryReport.aaveOracle,
      setupReport.rewardsControllerProxy,
      treasury,
      tokensReport.aToken,
      tokensReport.variableDebtToken
    );

    return helpersBatchOne.getConfigEngineReport();
  }

  function _deployHelpersBatch2(
    address pool,
    address rewardsController,
    address proxyAdmin
  ) internal returns (StaticATokenReport memory) {
    AaveV3HelpersBatchTwo helpersBatchTwo = new AaveV3HelpersBatchTwo(
      pool,
      rewardsController,
      proxyAdmin
    );

    return helpersBatchTwo.staticATokenReport();
  }

  function _deployMisc(
    bool l2Flag,
    address poolAddressesProvider,
    address sequencerUptimeOracle,
    uint256 gracePeriod
  ) internal returns (MiscReport memory) {
    AaveV3MiscBatch miscBatch = new AaveV3MiscBatch(
      l2Flag,
      poolAddressesProvider,
      sequencerUptimeOracle,
      gracePeriod
    );

    return miscBatch.getMiscReport();
  }

  function _deployPoolImplementations(
    address poolAddressesProvider,
    DeployFlags memory flags
  ) internal returns (PoolReport memory) {
    IPoolReport poolBatch;

    if (flags.l2) {
      poolBatch = IPoolReport(new AaveV3L2PoolBatch(poolAddressesProvider));
    } else {
      poolBatch = IPoolReport(new AaveV3PoolBatch(poolAddressesProvider));
    }

    return poolBatch.getPoolReport();
  }

  function _deployPeripherals(
    Roles memory roles,
    MarketConfig memory config,
    address poolAddressesProvider,
    address setupBatch
  ) internal returns (PeripheryReport memory) {
    AaveV3PeripheryBatch peripheryBatch = new AaveV3PeripheryBatch(
      roles.poolAdmin,
      config,
      poolAddressesProvider,
      setupBatch
    );

    return peripheryBatch.getPeripheryReport();
  }

  function _deployParaswapAdapters(
    Roles memory roles,
    MarketConfig memory config,
    address poolAddressesProvider,
    address treasury
  ) internal returns (ParaswapReport memory) {
    if (config.paraswapAugustusRegistry != address(0) && config.paraswapFeeClaimer != address(0)) {
      AaveV3ParaswapBatch parawswapBatch = new AaveV3ParaswapBatch(
        roles.poolAdmin,
        config,
        poolAddressesProvider,
        treasury
      );
      return parawswapBatch.getParaswapReport();
    }

    return
      ParaswapReport({
        paraSwapLiquiditySwapAdapter: address(0),
        paraSwapRepayAdapter: address(0),
        paraSwapWithdrawSwapAdapter: address(0),
        aaveParaSwapFeeClaimer: address(0)
      });
  }

  function _deployTokens(
    address poolProxy
  ) internal returns (AaveV3TokensBatch.TokensReport memory) {
    AaveV3TokensBatch tokensBatch = new AaveV3TokensBatch(poolProxy);

    return tokensBatch.getTokensReport();
  }

  function _generateMarketReport(
    InitialReport memory initialReport,
    AaveV3GettersBatchOne.GettersReportBatchOne memory gettersReportOne,
    AaveV3GettersBatchTwo.GettersReportBatchTwo memory gettersReportTwo,
    PoolReport memory poolReport,
    PeripheryReport memory peripheryReport,
    MiscReport memory miscReport,
    ParaswapReport memory paraswapReport,
    SetupReport memory setupReport,
    AaveV3TokensBatch.TokensReport memory tokensReport,
    ConfigEngineReport memory configEngineReport,
    StaticATokenReport memory staticATokenReport
  ) internal pure returns (MarketReport memory) {
    MarketReport memory report;

    report.poolAddressesProvider = initialReport.poolAddressesProvider;
    report.poolAddressesProviderRegistry = initialReport.poolAddressesProviderRegistry;
    report.emissionManager = peripheryReport.emissionManager;
    report.rewardsControllerImplementation = peripheryReport.rewardsControllerImplementation;
    report.walletBalanceProvider = gettersReportOne.walletBalanceProvider;
    report.uiIncentiveDataProvider = gettersReportOne.uiIncentiveDataProvider;
    report.protocolDataProvider = gettersReportOne.protocolDataProvider;
    report.uiPoolDataProvider = gettersReportOne.uiPoolDataProvider;
    report.poolImplementation = poolReport.poolImplementation;
    report.wrappedTokenGateway = gettersReportTwo.wrappedTokenGateway;
    report.l2Encoder = gettersReportTwo.l2Encoder;
    report.poolConfiguratorImplementation = poolReport.poolConfiguratorImplementation;
    report.aaveOracle = peripheryReport.aaveOracle;
    report.paraSwapLiquiditySwapAdapter = paraswapReport.paraSwapLiquiditySwapAdapter;
    report.paraSwapRepayAdapter = paraswapReport.paraSwapRepayAdapter;
    report.paraSwapWithdrawSwapAdapter = paraswapReport.paraSwapWithdrawSwapAdapter;
    report.aaveParaSwapFeeClaimer = paraswapReport.aaveParaSwapFeeClaimer;
    report.treasuryImplementation = peripheryReport.treasuryImplementation;
    report.proxyAdmin = peripheryReport.proxyAdmin;
    report.treasury = peripheryReport.treasury;
    report.poolProxy = setupReport.poolProxy;
    report.poolConfiguratorProxy = setupReport.poolConfiguratorProxy;
    report.rewardsControllerProxy = setupReport.rewardsControllerProxy;
    report.aclManager = setupReport.aclManager;
    report.aToken = tokensReport.aToken;
    report.variableDebtToken = tokensReport.variableDebtToken;
    report.priceOracleSentinel = miscReport.priceOracleSentinel;
    report.defaultInterestRateStrategy = miscReport.defaultInterestRateStrategy;
    report.configEngine = configEngineReport.configEngine;
    report.staticATokenFactoryImplementation = staticATokenReport.staticATokenFactoryImplementation;
    report.staticATokenFactoryProxy = staticATokenReport.staticATokenFactoryProxy;
    report.staticATokenImplementation = staticATokenReport.staticATokenImplementation;
    report.transparentProxyFactory = staticATokenReport.transparentProxyFactory;
    report.revenueSplitter = peripheryReport.revenueSplitter;

    return report;
  }
}
