// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LongTailOracleAdapters} from './LongTailOracleAdapters.sol';
import {CeloScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

contract DeployLongTailOracleAdaptersCelo is CeloScript {
  function run() external broadcast {
    LongTailOracleAdapters.deployAll(42220);
  }
}
