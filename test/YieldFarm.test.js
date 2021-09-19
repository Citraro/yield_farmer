const { default: web3 } = require('web3')
import { DAI_ADDRESS, EVM_REVERT, DAI_CONTRACT,largeDAIAddress, ether} from './helper'

const { USER_ADDRESS } = process.env;

const YieldFarm = artifacts.require('./YieldFarm')

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('YieldFarm',([user]) => {
    let yieldFarm

    beforeEach(async () => {
        //deploy farm
        yieldFarm = await YieldFarm.new(DAI_ADDRESS)

        //transfer dai to test user account
        await DAI_CONTRACT().methods
        .transfer(user, ether(1))
        .send({from: largeDAIAddress})

        await DAI_CONTRACT().methods
        .approve(yieldFarm.address, ether(1))
        .send( {from: user} )

    })

    describe('deployment', () => {
        it('name is correct', async () => {
            let result = await yieldFarm.name()
            result.should.equal('Dai Yield Farm')
        })
        it('eth address is correct', async () => {
            let result = await yieldFarm.daiToken()
            result.should.equal(DAI_ADDRESS)
        })
    })

    describe('deposit Dai', () => {
        describe('success', () => {
            let balance
            let result
            it('deposits dai to yieldfarm', async () => {
                await yieldFarm.depositDai(DAI_ADDRESS,ether(.1), {from: user})
                balance =  await yieldFarm.balanceOf(user)
                balance.toString().should.equal(ether(.1))
            })
        })
    })

})