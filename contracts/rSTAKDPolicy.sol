// SPDX-License-Identifier: MIT

/*

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

pragma solidity 0.6.12;
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

/**
 * @title Various utilities useful for uint256.
 */
library UInt256Lib {
    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    /**
     * @dev Safely converts a uint256 to an int256.
     */
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        require(a <= MAX_INT256);
        return int256(a);
    }
}

interface IrSTAKD {
    function totalSupply() external view returns (uint256);

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        returns (uint256);
}

contract rSTAKDPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    event LogRebase(
        uint256 indexed epoch,
        int256 ratio,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );
    event RatioSet(int256 ratio, uint256 timestamp);

    IrSTAKD public rSTAKD;
    uint256 public rebaseCooldown;
    uint256 public lastRebaseTimestamp;
    uint256 public epoch;
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_SUPPLY = 10000000 ether; //10 mil max supply
    uint256 private constant MIN_SUPPLY = 100000 ether; //100k minimum
    int256 public ratio;
    address public operator;

    bool public rebaseLocked;

    modifier onlyOwnerOperator() {
        require(msg.sender == owner() || msg.sender == operator);
        _;
    }

    constructor(address _stakd) public {
        rebaseCooldown = 20 hours;
        rebaseLocked = false;
        operator = msg.sender;
        rSTAKD = IrSTAKD(_stakd);
    }

    function setRebaseLocked(bool _locked) external onlyOwner {
        rebaseLocked = _locked;
    }

    function setOperator(address _addy) external onlyOwner {
        require(_addy != address(0), "Addres not correct.");
        operator = _addy;
    }

    function cooldownExpiryTimestamp() public view returns (uint256) {
        return lastRebaseTimestamp.add(rebaseCooldown);
    }

    function rebase() external onlyOwnerOperator {
        require(
            block.timestamp >= cooldownExpiryTimestamp(),
            "Rebase cooldown"
        );
         require(!rebaseLocked,"Rebase is locked");
        int256 supplyDelta = getRebaseValues();

        if (supplyDelta == 0) {
            emit LogRebase(epoch, ratio, supplyDelta, block.timestamp);
            return;
        }
        uint256 supplyAfterRebase = rSTAKD.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        lastRebaseTimestamp = block.timestamp;
        epoch = epoch.add(1);
        emit LogRebase(epoch, ratio, supplyDelta, block.timestamp);
    }

    function getRebaseValues() public view returns (int256) {
        int256 ratioSupply = ratio.mul(rSTAKD.totalSupply().toInt256Safe());
        ratioSupply = ratioSupply.div(1e18);
        int256 supplyDelta;
        if (ratioSupply > 0) {
            supplyDelta = rSTAKD.totalSupply().toInt256Safe().sub(ratioSupply);
        } else {
            supplyDelta = ratioSupply.abs().sub(
                rSTAKD.totalSupply().toInt256Safe()
            );
        }
        // supplyDelta = supplyDelta.div(1e18);
        return (supplyDelta);
    }

    function setRatio(int256 _ratio) external {
        //calculation happens offchain
        require(_ratio > 0, "Ratio must be higher than 0");
        ratio = _ratio;
        emit RatioSet(_ratio, block.timestamp);
    }
}
