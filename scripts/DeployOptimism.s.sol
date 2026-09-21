// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LongTailOracleAdapters} from './LongTailOracleAdapters.sol';
import {OptimismScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

contract DeployLongTailOracleAdaptersOptimism is OptimismScript {
  function run() external broadcast {
    LongTailOracleAdapters.deployAll(10);
  }
}
