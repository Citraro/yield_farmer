const YieldFarm = artifacts.require("YieldFarm");

const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";

module.exports = async (deployer) => {
  await deployer.deploy(YieldFarm, DAI_ADDRESS);
};
