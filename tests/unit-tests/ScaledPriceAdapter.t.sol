// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {ScaledPriceAdapter} from '../../src/contracts/misc-adapters/ScaledPriceAdapter.sol';
import {ChainlinkAggregatorMock} from './mocks/ChainlinkAggregatorMock.sol';

contract ScaledPriceAdapterTest is Test {
  function test_adapter_less_than_base() public {
    test_fuzz_adapter({sourceDecimals: 2, price: 1e2});
    test_fuzz_adapter({sourceDecimals: 6, price: 32.323e6});
  }

  function test_adapter_greater_than_base() public {
    test_fuzz_adapter({sourceDecimals: 12, price: 1e12});
  }

  function test_adapter_equal_to_base() public {
    test_fuzz_adapter({sourceDecimals: 8, price: 1e8});
  }

  function test_fuzz_adapter(uint256 sourceDecimals, int256 price) public {
    sourceDecimals = bound(sourceDecimals, 1, 36);
    price = bound(price, 0, int256(10 ** (10 + sourceDecimals)));
    ChainlinkAggregatorMock source = new ChainlinkAggregatorMock(price);
    source.setDecimals(uint8(sourceDecimals));
    ScaledPriceAdapter adapter = new ScaledPriceAdapter(address(source));

    (bool scaleUp, uint256 scale) = adapter.scale();
    assertEq(adapter.decimals(), 8);
    assertEq(scaleUp, adapter.decimals() > sourceDecimals);
    assertEq(
      scale,
      10 ** (scaleUp ? adapter.decimals() - sourceDecimals : sourceDecimals - adapter.decimals())
    );
    assertEq(adapter.latestAnswer(), scaleUp ? price * int256(scale) : price / int256(scale));
    assertEq(adapter.source(), address(source));
  }

  function test_adapter_invalid_source_feed() public {
    vm.expectRevert();
    new ScaledPriceAdapter(makeAddr('invalid'));
  }
}
