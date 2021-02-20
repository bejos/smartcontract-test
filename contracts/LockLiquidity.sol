pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

contract LockLiquidity is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    uint256 public lockDuration = 30 days; //change to any amount
    uint256 public lockDate;
    uint256 public lockAmount;

    event LiquidityLocked(uint256 amount, uint256 duration);
    event LiquidityUnlocked(uint256 amount);

    constructor(
    ) public {
    }

    function lockLiquidity(address _lptoken, uint256 _amount) external onlyOwner{
        IBEP20 lptoken = IBEP20(_lptoken);
        lptoken.safeTransferFrom(msg.sender,address(this),_amount);
        lockDate = block.timestamp;
        lockAmount = _amount;
        emit LiquidityLocked(_amount, lockDuration);

    }

    function unlockLiquidity(address _lptoken) external onlyOwner {
        require(block.timestamp >= lockDate.add(lockDuration),"can't unlock yet dude");
         IBEP20 lptoken = IBEP20(_lptoken);
        lptoken.safeTransfer(address(owner()),lockAmount);
        emit LiquidityUnlocked(lockAmount);
    }

}
