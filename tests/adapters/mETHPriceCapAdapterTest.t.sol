// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';

contract mETHMantleTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMantle.mETHAdapterCode(),
      // @dev the mETH/ETH exchange rate feed on Mantle was only deployed around block 98303759,
      // so the retrospective window plus the 7 days snapshot delay has to stay within its history
      10,
      ForkParams({network: 'mantle', blockNumber: 99140000}),
      'mETH_Mantle'
    )
  {}
}
