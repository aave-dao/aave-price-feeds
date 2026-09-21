// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LongTailOracleAdapters} from './LongTailOracleAdapters.sol';
import {OptimismScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

contract DeployLongTailOracleAdaptersOptimism is OptimismScript {
  function run() external broadcast {
    // https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
    LongTailOracleAdapters.deployAll(block.chainid);
  }
}
