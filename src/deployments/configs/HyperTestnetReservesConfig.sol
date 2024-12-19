// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';
import {MintableLimitERC20} from 'src/contracts/mocks/tokens/MintableLimitERC20.sol';
import {testWETH9} from 'src/contracts/dependencies/weth/testWETH9.sol';
import {IAaveOracle} from 'src/contracts/interfaces/IAaveOracle.sol';
import {IPoolConfigurator} from 'src/contracts/interfaces/IPoolConfigurator.sol';
import {IPool} from 'src/contracts/interfaces/IPool.sol';
import {ConfiguratorInputTypes} from 'src/contracts/protocol/libraries/types/ConfiguratorInputTypes.sol';
import {IDefaultInterestRateStrategyV2} from 'src/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import {AaveV3SetupBatch} from 'src/deployments/projects/aave-v3-batched/batches/AaveV3SetupBatch.sol';
import {MarketReport} from 'src/deployments/interfaces/IMarketReportTypes.sol';
import {IACLManager} from 'src/contracts/interfaces/IACLManager.sol';
import {HyperTestnetMarketInput, MarketConfig} from 'src/deployments/inputs/HyperTestnetMarketInput.sol';
import {UiPoolDataProviderV3, IUiPoolDataProviderV3,IPoolAddressesProvider} from 'src/contracts/helpers/UiPoolDataProviderV3.sol';
import {IEACAggregatorProxy} from 'src/contracts/helpers/interfaces/IEACAggregatorProxy.sol';
import 'forge-std/console.sol';

contract HyperTestnetReservesConfig is HyperTestnetMarketInput {

  AaveV3SetupBatch public constant MARKET_REPORT = AaveV3SetupBatch(0xD276bca6f14cd153B8473D65600D59BB641660D7);

  function _deployTestnetTokens(
    address deployer
  )
    internal
    returns (
        address[] memory tokens,
        address[] memory oracles
    )
  { 
    MarketConfig memory config;

    console.log('Aave V3 Batch Deployment');
    console.log('sender', msg.sender);

    (,config,,) = _getMarketInput(msg.sender);

    tokens  = new address[](4);

    tokens[0] = address(config.wrappedNativeToken); // config.wrappedNativeToken
    tokens[1] = address(new MintableLimitERC20('USD Coin', 'USDC', 6, 1000e6));
    tokens[2] = address(new MintableLimitERC20('Staked USDe', 'sUSDe', 18, 1000e18));
    // tokens[3] = address(0xe2fbc9cb335a65201fcde55323ae0f4e8a96a616); // stHYPE
    tokens[0] = address(new MintableLimitERC20('Solv BTC', 'SolvBTC', 18, 0.1e18));

    oracles = new address[](1);

    // oracles[0] = address(config.networkBaseTokenPriceInUsdProxyAggregator); //config.networkBaseTokenPriceInUsdProxyAggregator
    // oracles[1] = address(new MockAggregator(1e8));
    // oracles[2] = address(new MockAggregator(100_000e8));
    oracles[0] = address(new MockAggregator(100_000e8));

    return (tokens, oracles);
  }

  function _fetchStableTokens()
    internal
    returns (
        address[] memory tokens
    )
  { 
    tokens  = new address[](2);
    
    // tokens[0] = address(0x8bf86549d308e50Db889cF843AEBd6b7B0d7BB9a); // WHYPE
    tokens[0] = address(0x6fDbAF3102eFC67ceE53EeFA4197BE36c8E1A094); // USDC
    tokens[1] = address(0x2222C34A8dd4Ea29743bf8eC4fF165E059839782); // sUSDe

    return tokens;
  }

  function _fetchTestnetTokens()
    internal
    returns (
        address[] memory tokens
    )
  { 
    tokens  = new address[](1);

    // tokens[0] = address(0x4B85aCF84b2593D67f6593D18504dBb3A337D3D8); // SolvBTC
    tokens[0] = address(0x8bf86549d308e50Db889cF843AEBd6b7B0d7BB9a); // WHYPE
    // tokens[2] = address(0x6fDbAF3102eFC67ceE53EeFA4197BE36c8E1A094); // USDC
    // tokens[3] = address(0x2222C34A8dd4Ea29743bf8eC4fF165E059839782); // sUSDe

    //0x9edA7E43821EedFb677A69066529F16DB3A2dD73 USDXL

    return tokens;
  }

  function _fetchTestnetOracles()
    internal
    returns (
        address[] memory oracles
    )
  { 
    oracles  = new address[](1);

    // oracles[0] = address(0x85C4F855Bc0609D2584405819EdAEa3aDAbfE97D); // SolvBTC
    oracles[0] = address(0xC3346631E0A9720582fB9CAbdBEA22BC2F57741b); // WHYPE
    // oracles[2] = address(0xa0f2EF6ceC437a4e5F6127d6C51E1B0d3A746911); // USDC
    // oracles[3] = address(0xa0f2EF6ceC437a4e5F6127d6C51E1B0d3A746911); // sUSDe

    // USDXL uses a static oracle price of 1e8

    return oracles;
  }

  function _faucetTokens(
    address[] memory tokens,
    uint256[] memory amounts,
    address[] memory recipients
  ) 
    internal
  {
    for (uint i; i < recipients.length; ){
      for (uint j; j < tokens.length; ){
        MintableLimitERC20(tokens[j]).mint(amounts[j]);
        MintableLimitERC20(tokens[j]).transfer(recipients[i], amounts[j]);
        unchecked {
          j++;
        }
      }
      unchecked {
        i++;
      }
    }

  }

  function _initReserves(
    address[] memory tokens
  ) 
    internal
  {
    ConfiguratorInputTypes.InitReserveInput[] memory inputs = new ConfiguratorInputTypes.InitReserveInput[](1);

    IDefaultInterestRateStrategyV2.InterestRateData memory rateData = IDefaultInterestRateStrategyV2.InterestRateData({
      optimalUsageRatio: uint16(80_00),
      baseVariableBorrowRate: uint32(1_00),
      variableRateSlope1: uint32(4_00),
      variableRateSlope2: uint32(60_00)
    });

    //IMarketReport
    MarketReport memory marketReport = AaveV3SetupBatch(MARKET_REPORT).getMarketReport();

    inputs[0] = ConfiguratorInputTypes.InitReserveInput({
      aTokenImpl: marketReport.aToken, // Address of the aToken implementation
      variableDebtTokenImpl: marketReport.variableDebtToken, // Address of the variable debt token implementation
      useVirtualBalance: true,
      interestRateStrategyAddress: marketReport.defaultInterestRateStrategy, // Address of the interest rate strategy
      underlyingAsset: tokens[0], // WETH address on Ethereum mainnet
      treasury: marketReport.treasury, // Address of the treasury
      incentivesController: marketReport.rewardsControllerProxy, // Address of the incentives controller
      aTokenName: 'SolvBTC Hypurr',
      aTokenSymbol: 'hwSolvBTC',
      variableDebtTokenName: 'SolvBTC Variable Debt Hypurr',
      variableDebtTokenSymbol: 'variableDebtSolvBTC',
      params: bytes(''), // Additional parameters for initialization
      interestRateData: abi.encode(rateData)
    });

    // inputs[0] = ConfiguratorInputTypes.InitReserveInput({
    //   aTokenImpl: marketReport.aToken, // Address of the aToken implementation
    //   variableDebtTokenImpl: marketReport.variableDebtToken, // Address of the variable debt token implementation
    //   useVirtualBalance: true,
    //   interestRateStrategyAddress: marketReport.defaultInterestRateStrategy, // Address of the interest rate strategy
    //   underlyingAsset: tokens[0], // WETH address on Ethereum mainnet
    //   treasury: marketReport.treasury, // Address of the treasury
    //   incentivesController: marketReport.rewardsControllerProxy, // Address of the incentives controller
    //   aTokenName: 'WHYPE Hypurr',
    //   aTokenSymbol: 'hwWHYPE',
    //   variableDebtTokenName: 'WHYPE Variable Debt Hypurr',
    //   variableDebtTokenSymbol: 'variableDebtWHYPE',
    //   params: bytes(''), // Additional parameters for initialization
    //   interestRateData: abi.encode(rateData)
    // });

    // inputs[1] = ConfiguratorInputTypes.InitReserveInput({
    //   aTokenImpl: marketReport.aToken, // Address of the aToken implementation
    //   variableDebtTokenImpl: marketReport.variableDebtToken, // Address of the variable debt token implementation
    //   useVirtualBalance: true,
    //   interestRateStrategyAddress: marketReport.defaultInterestRateStrategy, // Address of the interest rate strategy
    //   underlyingAsset: tokens[1], // WETH address on Ethereum mainnet
    //   treasury: marketReport.treasury, // Address of the treasury
    //   incentivesController: marketReport.rewardsControllerProxy, // Address of the incentives controller
    //   aTokenName: 'USDC Hypurr',
    //   aTokenSymbol: 'hwUSDC',
    //   variableDebtTokenName: 'USDC Variable Debt Hypurr',
    //   variableDebtTokenSymbol: 'variableDebtUSDC',
    //   params: bytes(''), // Additional parameters for initialization
    //   interestRateData: abi.encode(rateData)
    // });

    // inputs[2] = ConfiguratorInputTypes.InitReserveInput({
    //   aTokenImpl: marketReport.aToken, // Address of the aToken implementation
    //   variableDebtTokenImpl: marketReport.variableDebtToken, // Address of the variable debt token implementation
    //   useVirtualBalance: true,
    //   interestRateStrategyAddress: marketReport.defaultInterestRateStrategy, // Address of the interest rate strategy
    //   underlyingAsset: tokens[2], // WETH address on Ethereum mainnet
    //   treasury: marketReport.treasury, // Address of the treasury
    //   incentivesController: marketReport.rewardsControllerProxy, // Address of the incentives controller
    //   aTokenName: 'sUSDe Hypurr',
    //   aTokenSymbol: 'hwsUSDe',
    //   variableDebtTokenName: 'sUSDe Variable Debt Hypurr',
    //   variableDebtTokenSymbol: 'variableDebtsUSDe',
    //   params: bytes(''), // Additional parameters for initialization
    //   interestRateData: abi.encode(rateData)
    // });
    
    // set reserves configs
    _getPoolConfigurator().initReserves(inputs);
  }

  function _enableCollateral(
    address[] memory tokens
  )
    internal
  {
    _getPoolConfigurator().configureReserveAsCollateral(
      tokens[0],
      8000, // LTV (80%)
      9000, // Liq. threshold (90%)
      10500 // Liq. bonus (5% tax)
    );
    // _getPoolConfigurator().configureReserveAsCollateral(
    //   tokens[1],
    //   8000, // LTV (80%)
    //   9000, // Liq. threshold (90%)
    //   10500 // Liq. bonus (5% tax)
    // );
    // _getPoolConfigurator().configureReserveAsCollateral(
    //   tokens[2],
    //   8000, // LTV (80%)
    //   9000, // Liq. threshold (90%)
    //   10500 // Liq. bonus (5% tax)
    // );
  }

  function _enableBorrowing(
    address[] memory tokens
  )
    internal
  {
    _getPoolConfigurator().setReserveBorrowing(tokens[0], true);
    // _getPoolConfigurator().setReserveBorrowing(tokens[1], true);
    // _getPoolConfigurator().setReserveBorrowing(tokens[2], true);
  }

  function _supplyPool(
    address[] memory tokens,
    uint256[] memory amounts,
    address onBehalfOf
  ) internal {
    for (uint i; i < tokens.length; ){
      // approve token amount
      MintableLimitERC20(tokens[i]).approve(address(_getPoolInstance()), amounts[i]);
      
      // supply tokens
      _getPoolInstance().supply(
        tokens[i],
        amounts[i],
        onBehalfOf,
        0
      );

      unchecked {
        i++;
      }
    }
  }

  function _addPoolAdmin(
    address newAdmin
  )
    internal
  {
    IACLManager(_getMarketReport().aclManager).addPoolAdmin(newAdmin);
  }

  function _setupEModeGroup(
    uint8 categoryId,
    string memory label,
    address[] memory collateralTokens,
    address[] memory borrowTokens,
    uint16 ltv,
    uint16 liquidationThreshold,
    uint16 liquidationBonus
  )
    internal
  {
    // setup emode category
    _getPoolConfigurator().setEModeCategory(
      categoryId,
      ltv,
      liquidationThreshold,
      liquidationBonus,
      label
    );

    // enable collateral tokens
    for (uint i; i < collateralTokens.length; ){
      _getPoolConfigurator().setAssetCollateralInEMode(collateralTokens[i], categoryId, true);

      unchecked {
        i++;
      }
    }

    // enable borrow tokens
    for (uint i; i < borrowTokens.length; ){
      _getPoolConfigurator().setAssetBorrowableInEMode(borrowTokens[i], categoryId, true);

      unchecked {
        i++;
      }
    }
  }

  function _deployUiPoolDataProvider()
    internal
  {
    MarketReport memory marketReport = _getMarketReport();
    marketReport.uiPoolDataProvider = address(new UiPoolDataProviderV3(
      IEACAggregatorProxy(0xC3346631E0A9720582fB9CAbdBEA22BC2F57741b),
      IEACAggregatorProxy(UiPoolDataProviderV3(marketReport.uiPoolDataProvider).marketReferenceCurrencyPriceInUsdProxyAggregator())
    ));
    _setMarketReport(marketReport);
  }

  function _getAaveOracle()
    internal
    view
    returns (
      IAaveOracle
    )
  {
    return IAaveOracle(_getMarketReport().aaveOracle);
  }

  function _getPoolConfigurator()
    internal
    view
    returns (
      IPoolConfigurator
    )
  {
    return IPoolConfigurator(_getMarketReport().poolConfiguratorProxy);
  }

  function _getPoolInstance()
    internal
    view
    returns (
      IPool
    )
  {
    return IPool(_getMarketReport().poolProxy);
  }

  function _getMarketReport()
    internal
    view
    returns (
      MarketReport memory
    ) {
      return AaveV3SetupBatch(MARKET_REPORT).getMarketReport();
  }

  function _setMarketReport(MarketReport memory marketReport)
    internal
  {
      return AaveV3SetupBatch(MARKET_REPORT).setMarketReport(marketReport);
  }

  function _getReservesList()
    internal
    view
    returns (
      address[] memory
    )
    {
      MarketReport memory marketReport = _getMarketReport();
      return IUiPoolDataProviderV3(
        _getMarketReport().uiPoolDataProvider
      ).getReservesList(
        IPoolAddressesProvider(marketReport.poolAddressesProvider)
      );
    }
}
