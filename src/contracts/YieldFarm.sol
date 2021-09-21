// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint8 id;
  }
    struct ReserveConfigurationMap {
    uint256 data;
  }

interface DaiToken{
    function transfer(address _to, uint _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
    function balanceOf(address _user) external view returns (uint);
    function approve(address _spender, uint256 _value) external returns (bool);
}

interface CErc20 { // Compound Erc20
    function mint(uint256) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function supplyRatePerBlock() external returns (uint256);
    function redeem(uint) external returns (uint);
    function redeemUnderlying(uint) external returns (uint);
    function balanceOfUnderlying(address account) external returns (uint);
    function balanceOf(address account) external returns (uint);
}

interface AErc20 { // Aave Erc20
    function mint(address user,uint256 amount,uint256 index) external returns (bool);
    function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);
}

interface LendingPool { // Aave Lending pool
    function deposit(address asset, uint256 amount, address onBehalfOf,uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    function getReserveData(address asset) external returns(ReserveData memory);
}



contract YieldFarm {
    using SafeMath for uint256;

    enum Provider {
        Aave,
        Compound
    }

    DaiToken public daiToken;
    CErc20 public cDaiToken;
    AErc20 public aDaiToken;
    LendingPool public Lending_Pool;


    Provider private aave = Provider(0);
    Provider private compound = Provider(1);

    string public name = "Dai Yield Farm"; // smoke test use case

    address constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant cDAI = address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643); // compound Dai reward
    address constant LendingPoolAddress = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address constant aDAI = address(0x028171bCA77440897B824Ca71D1c56caC55b68A3);

    mapping(address => Provider) public usersProvider;

    mapping(address => uint256) public balanceOf;

    event Deposit(address staker, uint256 amount, uint256 balance, Provider provider);
    event Withdrawl(address staker, uint256 amount, uint256 balance);
    event Rebalance(address staker, uint256 balance);

    constructor(DaiToken _daiToken, CErc20 _cDaiToken, AErc20 _aDaiToken, LendingPool _lendingPool) public {
        daiToken = _daiToken;
        cDaiToken = _cDaiToken;
        aDaiToken = _aDaiToken;
        Lending_Pool = _lendingPool;
    }

    // deposit dai
    function depositDai(address _token, uint256 _amount) public{
        require(_token == DAI, "You may only deposit Dai");
        require(daiToken.balanceOf(msg.sender) >= _amount, "You must have enough tokens to send");
        require(daiToken.transferFrom(msg.sender, address(this), _amount));

        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);

        Provider betterRateProvider = getBestRate();
        if(betterRateProvider == aave){
            depositDaiToAave(_amount);
        }else{
            depositDaiToCompound(_amount);
        }
    }

    function depositDaiToCompound(uint256 _amount) internal {
        daiToken.approve(cDAI, _amount);
        assert(cDaiToken.mint(_amount) == 0); // 0 = success 
        usersProvider[msg.sender] = compound;
        emit Deposit(msg.sender,_amount,balanceOf[msg.sender],compound);
    }

    function depositDaiToAave(uint256 _amount) internal {
        daiToken.approve(address(Lending_Pool),_amount);
        Lending_Pool.deposit(DAI,_amount,msg.sender,0); // 0 = no referalcode 
        usersProvider[msg.sender] = aave;
        emit Deposit(msg.sender,_amount,balanceOf[msg.sender],aave);
    }

    function redeemFromCompound(uint256 _amount) internal{
        require(cDaiToken.redeemUnderlying(_amount) == 0, "redeem failed");
    }

    function reedeemFromAave(uint _amount) internal {
        Lending_Pool.withdraw(DAI, _amount, msg.sender);
    }

    // withdrawl Dai
    function withdrawlDai(address _token, uint256 _amount) public {
        require(_token == DAI, "You may only deposit Dai");
        require(balanceOf[msg.sender] >= _amount, "You must have enough tokens to withdrawl");
        if(usersProvider[msg.sender] == aave){
            reedeemFromAave(_amount);
        }else{
            redeemFromCompound(_amount);
        }


        require(daiToken.transferFrom(address(this), msg.sender, _amount));
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        emit Withdrawl(msg.sender, _amount, balanceOf[msg.sender]);
    }

    // rebalance dai

    //check for best rate
    function getBestRate() internal returns (Provider) {
        Provider bestRateProvider;
        ReserveData memory returnData;

        bestRateProvider = Provider(0); // aave by default

        //get AAVE data
        returnData = Lending_Pool.getReserveData(DAI);
        if (returnData.currentLiquidityRate < cDaiToken.supplyRatePerBlock()){
            bestRateProvider = Provider(1);
        }

        return bestRateProvider;
    }

}