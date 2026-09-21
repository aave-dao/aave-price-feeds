// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LongTailOracleAdapters} from './LongTailOracleAdapters.sol';
import {CeloScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

contract DeployLongTailOracleAdaptersCelo is CeloScript {
  function run() external broadcast {
    // https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
    LongTailOracleAdapters.deployAll(block.chainid);
  }
}
