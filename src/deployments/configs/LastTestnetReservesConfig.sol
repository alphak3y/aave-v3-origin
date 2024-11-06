// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';
import {MintableERC20} from 'src/contracts/mocks/tokens/MintableERC20.sol';
import {IAaveOracle} from 'src/contracts/interfaces/IAaveOracle.sol';
import {IPoolConfigurator} from 'src/contracts/interfaces/IPoolConfigurator.sol';
import {ConfiguratorInputTypes} from 'src/contracts/protocol/libraries/types/ConfiguratorInputTypes.sol';
import {IDefaultInterestRateStrategyV2} from 'src/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import 'forge-std/console.sol';

contract LastTestnetReservesConfig {
  function _deployTestnetTokens(
    address deployer
  )
    internal
    returns (
        address[] memory tokens,
        address[] memory oracles
    )
  { 
    tokens  = new address[](3);
    
    tokens[0] = address(new MintableERC20('Wrapped Ether', 'WETH', 18));
    tokens[1] = address(new MintableERC20('USD Coin', 'USDC', 6));
    tokens[2] = address(new MintableERC20('Tether USD', 'USDT', 6));

    oracles = new address[](3);

    oracles[0] = address(new MockAggregator(1800e8));
    oracles[1] = address(new MockAggregator(1e8));
    oracles[2] = address(new MockAggregator(1e8));

    return (tokens, oracles);
  }

  function _initReserves(
    address[] memory tokens
  ) 
    internal
  {
    ConfiguratorInputTypes.InitReserveInput[] memory inputs = new ConfiguratorInputTypes.InitReserveInput[](3);

    IDefaultInterestRateStrategyV2.InterestRateData memory rateData = IDefaultInterestRateStrategyV2.InterestRateData({
      optimalUsageRatio: uint16(80_00),
      baseVariableBorrowRate: uint32(1_00),
      variableRateSlope1: uint32(4_00),
      variableRateSlope2: uint32(60_00)
    });

    inputs[0] = ConfiguratorInputTypes.InitReserveInput({
      aTokenImpl: address(0xEcfc9497777345BEda45506deA064c2e17B06B8c), // Address of the aToken implementation
      variableDebtTokenImpl: address(0x49526edA124F2295BBF0f02817D1bB27E1C6F23E ), // Address of the variable debt token implementation
      useVirtualBalance: false, // Set to false for WETH
      interestRateStrategyAddress: address(0xDeaeA8D8769a14092d381Ac44D9cfB5638D68478), // Address of the interest rate strategy
      underlyingAsset: address(tokens[0]), // WETH address on Ethereum mainnet
      treasury: address(0xa2CCdD20525d5225b4AB08c10D1aFfb6de84D518), // Address of the treasury
      incentivesController: address(0x21455b64CD8f992B2500a55243d2C179a77C83A1), // Address of the incentives controller
      aTokenName: 'WETH Aave',
      aTokenSymbol: 'awWETH',
      variableDebtTokenName: 'WETH Variable Debt Aave',
      variableDebtTokenSymbol: 'variableDebtWETH',
      params: bytes(''), // Additional parameters for initialization
      interestRateData: abi.encode(rateData)
    });

    inputs[1] = ConfiguratorInputTypes.InitReserveInput({
      aTokenImpl: address(0xEcfc9497777345BEda45506deA064c2e17B06B8c), // Address of the aToken implementation
      variableDebtTokenImpl: address(0x49526edA124F2295BBF0f02817D1bB27E1C6F23E ), // Address of the variable debt token implementation
      useVirtualBalance: false, // Set to false for WETH
      interestRateStrategyAddress: address(0xDeaeA8D8769a14092d381Ac44D9cfB5638D68478), // Address of the interest rate strategy
      underlyingAsset: address(tokens[1]), // WETH address on Ethereum mainnet
      treasury: address(0xa2CCdD20525d5225b4AB08c10D1aFfb6de84D518), // Address of the treasury
      incentivesController: address(0x21455b64CD8f992B2500a55243d2C179a77C83A1), // Address of the incentives controller
      aTokenName: 'USDC Aave',
      aTokenSymbol: 'awUSDC',
      variableDebtTokenName: 'USDC Variable Debt Aave',
      variableDebtTokenSymbol: 'variableDebtUSDC',
      params: bytes(''), // Additional parameters for initialization
      interestRateData: abi.encode(rateData)
    });

    inputs[2] = ConfiguratorInputTypes.InitReserveInput({
      aTokenImpl: address(0xEcfc9497777345BEda45506deA064c2e17B06B8c), // Address of the aToken implementation
      variableDebtTokenImpl: address(0x49526edA124F2295BBF0f02817D1bB27E1C6F23E ), // Address of the variable debt token implementation
      useVirtualBalance: true, // Set to true for WETH
      interestRateStrategyAddress: address(0xDeaeA8D8769a14092d381Ac44D9cfB5638D68478), // Address of the interest rate strategy
      underlyingAsset: address(tokens[2]), // WETH address on Ethereum mainnet
      treasury: address(0xa2CCdD20525d5225b4AB08c10D1aFfb6de84D518), // Address of the treasury
      incentivesController: address(0x21455b64CD8f992B2500a55243d2C179a77C83A1), // Address of the incentives controller
      aTokenName: 'USDT Aave',
      aTokenSymbol: 'awUSDT',
      variableDebtTokenName: 'USDT Variable Debt Aave',
      variableDebtTokenSymbol: 'variableDebtUSDT',
      params: bytes(''), // Additional parameters for initialization
      interestRateData: abi.encode(rateData)
    });
    
    // set reserves configs
    _getPoolConfigurator().initReserves(inputs);
  }

  function _enableBorrowing(
    address[] memory tokens
  )
    internal
  {
    _getPoolConfigurator().setReserveBorrowing(tokens[0], true);
    _getPoolConfigurator().setReserveBorrowing(tokens[1], true);
    _getPoolConfigurator().setReserveBorrowing(tokens[2], true);
  }

  function _getAaveOracle()
    internal
    pure
    returns (
      IAaveOracle
    )
  {
    return IAaveOracle(0xE6C26ED28215f2bb33C3F97768d250eFC98586b4);
  }

  function _getPoolConfigurator()
    internal
    pure
    returns (
      IPoolConfigurator
    )
  {
    return IPoolConfigurator(0x4c1E6019200329A039d5AD5b577838967250c0C3);
  }
}
