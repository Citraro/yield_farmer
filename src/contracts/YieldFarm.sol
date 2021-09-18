// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

interface DaiToken{
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address from, address to, uint wad) external returns (bool);
    function balanceOf(address user) external view returns (uint);
    function approve(address _spender, uint256 _value) external returns (bool);
}


contract YieldFarm {
    using SafeMath for uint256;

    DaiToken public daiToken;

    string public name = "Dai Yield Farm"; // smoke test use case

    address constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI eth address
    
    mapping(address => uint256) public balanceOf;

    event Deposit(address staker, uint256 amount, uint256 balance);
    event Withdrawl(address staker, uint256 amount, uint256 balance);
    event Rebalance(address staker, uint256 amount, uint256 balance);

    constructor(DaiToken _daiToken) public {
        daiToken = _daiToken;
    }

    // deposit dai
    function depositDai(address _token, uint256 _amount) public {
        require(_token == DAI, "You may only deposit Dai");
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
        emit Deposit(msg.sender,_amount,balanceOf[msg.sender]);
    }

    // withdrawl Dai

    // rebalance dai


}