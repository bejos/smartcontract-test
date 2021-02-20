pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";

pragma solidity 0.6.12;

contract STAKDSale {
    address payable public collector =
        0x24A6578b8ccB13043f4Ef4E131e8A591E89B1b97;
    uint256 public minAmount = 0.5 ether;
    uint256 public maxAmount = 10 ether;
    uint256 public capAmount = 1000 ether;
    uint256 public bnbRaised;
    bool public saleActive = false;

    constructor() public {}

    fallback() external payable {
        buyTokens();
    }

    receive() external payable {
        buyTokens();
    }

    function setActive() external {
        require(msg.sender == address(collector), "nice try");
        saleActive = !saleActive;
    }

    function buyTokens() public payable {
        require(msg.sender != address(0));
        require(
            msg.value >= minAmount && msg.value <= maxAmount,
            "Not correct amount"
        );
        require(saleActive, "sale not active");
        require(msg.value + bnbRaised <= capAmount, "Cap reached!");
        bnbRaised = bnbRaised + msg.value;
        (bool sent, bytes memory data) = collector.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function drainBNB() external {
        //if any bnb is left in the contract
        require(msg.sender == address(collector), "nice try");
        collector.transfer(address(this).balance);
    }
}
