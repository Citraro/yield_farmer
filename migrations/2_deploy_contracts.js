const YieldFarm = artifacts.require("YieldFarm");

const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const CDAI_ADDRESS = '0x5d3a536e4d6dbd6114cc1ead35777bab948e3643';
const ADAI_ADDRESS = '0x028171bCA77440897B824Ca71D1c56caC55b68A3';
const LENDINGPOOL_ADDRESS = '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9';

module.exports = async (deployer) => {
  await deployer.deploy(YieldFarm, DAI_ADDRESS,CDAI_ADDRESS,ADAI_ADDRESS,LENDINGPOOL_ADDRESS, YieldFarm);
};
