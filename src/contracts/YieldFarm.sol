// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

interface DaiToken{
    function transfer(address _to, uint _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
    function balanceOf(address _user) external view returns (uint);
    function approve(address _spender, uint256 _value) external returns (bool);
}

interface CErc20 {
    function mint(uint256) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function supplyRatePerBlock() external returns (uint256);
    function redeem(uint) external returns (uint);
    function redeemUnderlying(uint) external returns (uint);
    function balanceOfUnderlying(address account) external returns (uint);
    function balanceOf(address account) external returns (uint);
}


contract YieldFarm {
    using SafeMath for uint256;

    enum Provider {
        Aave,
        Compound
    }

    DaiToken public daiToken;
    CErc20 public cDaiToken;
    Provider private aave = Provider(0);
    Provider private compound = Provider(1);

    string public name = "Dai Yield Farm"; // smoke test use case

    address constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant cDAI = address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643); // compound Dai reward

    mapping(address => Provider) public usersProvider;

    mapping(address => uint256) public balanceOf;

    event Deposit(address staker, uint256 amount, uint256 balance);
    event Withdrawl(address staker, uint256 amount, uint256 balance);
    event Rebalance(address staker, uint256 balance);

    constructor(DaiToken _daiToken, CErc20 _cDaiToken) public {
        daiToken = _daiToken;
        cDaiToken = _cDaiToken;
    }

    // deposit dai
    function depositDai(address _token, uint256 _amount) public{
        require(_token == DAI, "You may only deposit Dai");
        require(daiToken.balanceOf(msg.sender) >= _amount, "You must have enough tokens to send");
        require(daiToken.transferFrom(msg.sender, address(this), _amount));
        // Approve transfer on the Dai contract
        daiToken.approve(cDAI, _amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);

        depositDaiToCompound(_amount);
    }

    function getCompoundPercentage() internal returns (uint256){
        return cDaiToken.exchangeRateCurrent();
    }

    function depositDaiToCompound(uint256 _amount) internal {
        // Mint cDai
        assert(cDaiToken.mint(_amount) == 0); // 0 = success 
        usersProvider[msg.sender] = compound;
        emit Deposit(msg.sender,_amount,balanceOf[msg.sender]);
    }

    function redeemFromCompound(uint256 _amount) internal{
        require(cDaiToken.redeemUnderlying(_amount) == 0, "redeem failed");
    }

    // withdrawl Dai
    function withdrawlDai(address _token, uint256 _amount) public {
        require(_token == DAI, "You may only deposit Dai");
        require(balanceOf[msg.sender] >= _amount, "You must have enough tokens to send");
        redeemFromCompound(_amount);

        require(daiToken.transferFrom(address(this), msg.sender, _amount));
        emit Withdrawl(msg.sender, _amount, balanceOf[msg.sender]);
    }

    // rebalance dai

    //check for best rate
    function getBestRate() internal returns (Provider) {
        uint256 interestRate;
        Provider bestRateProvider;

        //TODO: Add aave 
        bestRateProvider = Provider(1);
        interestRate = cDaiToken.supplyRatePerBlock();

        return bestRateProvider;
    }

}