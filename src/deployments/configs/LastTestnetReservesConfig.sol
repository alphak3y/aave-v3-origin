// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {MockAggregator} from 'src/contracts/mocks/oracle/CLAggregators/MockAggregator.sol';
import {MintableERC20} from 'src/contracts/mocks/tokens/MintableERC20.sol';
import {testWETH9} from 'src/contracts/dependencies/weth/testWETH9.sol';
import {IAaveOracle} from 'src/contracts/interfaces/IAaveOracle.sol';
import {IPoolConfigurator} from 'src/contracts/interfaces/IPoolConfigurator.sol';
import {IPool} from 'src/contracts/interfaces/IPool.sol';
import {ConfiguratorInputTypes} from 'src/contracts/protocol/libraries/types/ConfiguratorInputTypes.sol';
import {IDefaultInterestRateStrategyV2} from 'src/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import {AaveV3SetupBatch} from 'src/deployments/projects/aave-v3-batched/batches/AaveV3SetupBatch.sol';
import {MarketReport} from 'src/deployments/interfaces/IMarketReportTypes.sol';
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

    tokens[0] = address(0x1B42442F2bDd70d581D0689342E315e699d36768); // config.wrappedNativeToken
    tokens[1] = address(new MintableERC20('USD Coin', 'USDC', 6));
    tokens[2] = address(new MintableERC20('Tether USD', 'USDT', 6));

    oracles = new address[](3);

    oracles[0] = address(0xB63E7eF70Ebdf52138Ec7A34f0C18019B51E7Ab6); //config.networkBaseTokenPriceInUsdProxyAggregator
    oracles[1] = address(new MockAggregator(1e8));
    oracles[2] = address(new MockAggregator(1e8));

    return (tokens, oracles);
  }

  function _fetchTestnetTokens(
    address deployer
  )
    internal
    returns (
        address[] memory tokens
    )
  { 
    tokens  = new address[](3);
    
    tokens[0] = address(0x7eA65834587ABF89A94d238a404C4A638Fc7641B); // WETH
    tokens[1] = address(0x04f42e29D6057B7D70Ea1cab8E516C0029420B64); // USDC
    tokens[2] = address(0xc9Fc065b2e986f29138Bd398E6FaAbd291c58B8E); // USDT

    return tokens;
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
        MintableERC20(tokens[j]).mint(amounts[j]);
        MintableERC20(tokens[j]).transfer(recipients[i], amounts[j]);
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
    address[] memory tokens,
    address marketReport
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
    MarketReport memory marketReport = AaveV3SetupBatch(marketReport).getMarketReport();

    // inputs[0] = ConfiguratorInputTypes.InitReserveInput({
    //   aTokenImpl: address(marketReport.), // Address of the aToken implementation
    //   variableDebtTokenImpl: address(0x49526edA124F2295BBF0f02817D1bB27E1C6F23E ), // Address of the variable debt token implementation
    //   useVirtualBalance: false, // TODO is this important? not mentioned in code or spark interface
    //   interestRateStrategyAddress: address(0xDeaeA8D8769a14092d381Ac44D9cfB5638D68478), // Address of the interest rate strategy
    //   underlyingAsset: address(tokens[0]), // WETH address on Ethereum mainnet
    //   treasury: address(0xa2CCdD20525d5225b4AB08c10D1aFfb6de84D518), // Address of the treasury
    //   incentivesController: address(0x21455b64CD8f992B2500a55243d2C179a77C83A1), // Address of the incentives controller
    //   aTokenName: 'testWETH Aave',
    //   aTokenSymbol: 'awtestWETH',
    //   variableDebtTokenName: 'Test WETH Variable Debt Aave',
    //   variableDebtTokenSymbol: 'variableDebtTestWETH',
    //   params: bytes(''), // Additional parameters for initialization
    //   interestRateData: abi.encode(rateData)
    // });

    // inputs[1] = ConfiguratorInputTypes.InitReserveInput({
    //   aTokenImpl: address(0xEcfc9497777345BEda45506deA064c2e17B06B8c), // Address of the aToken implementation
    //   variableDebtTokenImpl: address(0x49526edA124F2295BBF0f02817D1bB27E1C6F23E ), // Address of the variable debt token implementation
    //   useVirtualBalance: false, // Set to false for WETH
    //   interestRateStrategyAddress: address(0xDeaeA8D8769a14092d381Ac44D9cfB5638D68478), // Address of the interest rate strategy
    //   underlyingAsset: address(tokens[1]), // WETH address on Ethereum mainnet
    //   treasury: address(0xa2CCdD20525d5225b4AB08c10D1aFfb6de84D518), // Address of the treasury
    //   incentivesController: address(0x21455b64CD8f992B2500a55243d2C179a77C83A1), // Address of the incentives controller
    //   aTokenName: 'USDC Aave',
    //   aTokenSymbol: 'awUSDC',
    //   variableDebtTokenName: 'USDC Variable Debt Aave',
    //   variableDebtTokenSymbol: 'variableDebtUSDC',
    //   params: bytes(''), // Additional parameters for initialization
    //   interestRateData: abi.encode(rateData)
    // });

    // inputs[2] = ConfiguratorInputTypes.InitReserveInput({
    //   aTokenImpl: address(0xEcfc9497777345BEda45506deA064c2e17B06B8c), // Address of the aToken implementation
    //   variableDebtTokenImpl: address(0x49526edA124F2295BBF0f02817D1bB27E1C6F23E ), // Address of the variable debt token implementation
    //   useVirtualBalance: true, // Set to true for WETH
    //   interestRateStrategyAddress: address(0xDeaeA8D8769a14092d381Ac44D9cfB5638D68478), // Address of the interest rate strategy
    //   underlyingAsset: address(tokens[2]), // WETH address on Ethereum mainnet
    //   treasury: address(0xa2CCdD20525d5225b4AB08c10D1aFfb6de84D518), // Address of the treasury
    //   incentivesController: address(0x21455b64CD8f992B2500a55243d2C179a77C83A1), // Address of the incentives controller
    //   aTokenName: 'USDT Aave',
    //   aTokenSymbol: 'awUSDT',
    //   variableDebtTokenName: 'USDT Variable Debt Aave',
    //   variableDebtTokenSymbol: 'variableDebtUSDT',
    //   params: bytes(''), // Additional parameters for initialization
    //   interestRateData: abi.encode(rateData)
    // });
    
    // set reserves configs
    // _getPoolConfigurator().initReserves(inputs);
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
      MintableERC20(tokens[i]).approve(address(_getPoolInstance()), amounts[i]);
      
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

  function _getPoolInstance()
    internal
    pure
    returns (
      IPool
    )
  {
    return IPool(0xBD2f32C02140641f497B0Db7B365122214f7c548);
  }
}
