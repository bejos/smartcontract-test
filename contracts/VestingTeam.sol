pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

contract VestingTeam is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 stakdToken; 

    uint256 public constant lockDuration = 30 days; //change to any amount
    uint256 public constant amountOfUnlocks = 300 days;
    uint256 public immutable vestingEnd;
    uint256 public constant unlockPerPeriod = 8000 ether;
    uint256 public immutable lockStartDate;
    uint256 public lastClaim;
    uint256 public actualClaim;

    event ClaimedTokens(uint256 amount);
    event LiquidityUnlocked(uint256 amount);

    constructor(
        address _stakdToken,
        uint256 _startTime
    ) public {
        stakdToken = IBEP20(_stakdToken);
        vestingEnd = amountOfUnlocks.add(_startTime);
        lockStartDate = _startTime;
    }

    function claimTokens() external onlyOwner {
        require(block.timestamp >= lockStartDate,"not yet claimable dude!");
        require(
            block.timestamp >= lastClaim.add(lockDuration),
            "delay since last claim not passed"
        );
        uint256 currentClaimPeriod = (block.timestamp.sub(lockStartDate)).div(lockDuration);
        if(currentClaimPeriod > actualClaim) {
            uint256 multi = currentClaimPeriod.sub(actualClaim);
            stakdToken.safeTransfer(address(owner()),unlockPerPeriod.mul(multi));
             emit ClaimedTokens(unlockPerPeriod.mul(multi));
        } else {
            stakdToken.safeTransfer(address(owner()),unlockPerPeriod);
             emit ClaimedTokens(unlockPerPeriod);
        }
        actualClaim = actualClaim +1;
       
    }

    function claimLeftovers() external {
        require(block.timestamp >= vestingEnd,"vesting not yet finished dude!");
        stakdToken.safeTransfer(address(owner()),stakdToken.balanceOf(address(this)));
    }

}
