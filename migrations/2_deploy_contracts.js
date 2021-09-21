const YieldFarm = artifacts.require("YieldFarm");

const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const CDAI_ADDRESS = '0x5d3a536e4d6dbd6114cc1ead35777bab948e3643';

module.exports = async (deployer) => {
  await deployer.deploy(YieldFarm, DAI_ADDRESS,CDAI_ADDRESS);
};
