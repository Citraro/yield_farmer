const { default: web3 } = require('web3')
import { DAI_ADDRESS, EVM_REVERT, DAI,largeDAIAddress } from './helper'

const YieldFarm = artifacts.require('./YieldFarm')

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('YieldFarm',([user1]) => {
    let yieldFarm

    beforeEach(async () => {
        //deploy farm
        yieldFarm = await YieldFarm.new(DAI_ADDRESS)
    })

    describe('deployment', () => {
        it('name is correct', async () => {
            let result = await yieldFarm.name()
            result.should.equal('Dai Yield Farm')
        })
        it('eth address is correct', async () => {
            let result = await yieldFarm.daiToken();
            result.should.equal(DAI_ADDRESS)
        })
    })

})