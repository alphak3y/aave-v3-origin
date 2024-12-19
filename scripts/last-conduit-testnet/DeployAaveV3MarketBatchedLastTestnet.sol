// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {DeployAaveV3MarketBatchedBase} from './misc/DeployAaveV3MarketBatchedBase.sol';

import {LastTestnetMarketInput} from '../src/deployments/inputs/LastTestnetMarketInput.sol';

contract Default is DeployAaveV3MarketBatchedBase, LastTestnetMarketInput {}
