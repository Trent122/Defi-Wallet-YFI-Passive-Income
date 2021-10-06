pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IYDAI {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function balanceOf(address _address) external view returns (uint256);

    function getPricePerFullShare() external view returns (uint256);
}

contract Wallet {
    address admin;
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IYDAI yDai = IYDAI(0xC2cB1040220768554cf699b0d863A3cd4324ce32);

    constructor() public {
        admin = msg.sender;
    }

    //+-Deposit and Automatically Invest our money in the Wallet using Yearn Finance:_
    function save(uint256 amount) external {
        dai.transferFrom(msg.sender, address(this), amount);
        _save(amount);
    }

    //+-Liquidate Automatically our Investment from Yearn Finance and Withdraw our Money:_
    function spend(uint256 amount, address recipient) external {
        require(msg.sender == admin, "only admin");
        uint256 balanceShares = yDai.balanceOf(address(this));
        yDai.withdraw(balanceShares);
        dai.transfer(recipient, amount);
        uint256 balanceDai = dai.balanceOf(address(this));
        if (balanceDai > 0) {
            _save(balanceDai);
        }
    }

    function _save(uint256 amount) internal {
        dai.approve(address(yDai), amount);
        yDai.deposit(amount);
    }

    //+-See the Balance in our Wallet:_
    function balance() external view returns (uint256) {
        uint256 price = yDai.getPricePerFullShare();
        uint256 balanceShares = yDai.balanceOf(address(this));
        return balanceShares * price;
    }
}
