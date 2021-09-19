const Web3 = require('web3')
const web3 = new Web3('http://localhost:8545')

export const DAI_ADDRESS = '0x6B175474E89094C44Da98b954EedeAC495271d0F'

export const EVM_REVERT = 'VM Exception while processing transaction: revert'

export const largeDAIAddress = "0xC564EE9f21Ed8A2d8E7e76c085740d5e4c5FaFbE"

export const ETHER_ADDRESS = '0x0000000000000000000000000000000000000000'

export const DAI_CONTRACT = () => {
    const daiAbi = require('./DAI.js')

    return new web3.eth.Contract(daiAbi, DAI_ADDRESS)
}

export const ether = (n) => {
    return new web3.utils.BN(
        web3.utils.toWei(n.toString(),'ether')
    ).toString()
}