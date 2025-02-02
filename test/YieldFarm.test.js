const { default: web3 } = require('web3')

import { DAI_ADDRESS, EVM_REVERT, DAI_CONTRACT,LARGE_DAI_ADDRESS, ether, 
    ETHER_ADDRESS, CDAI_ADDRESS, ADAI_ADDRESS, LENDINGPOOL_ADDRESS, ADAI_CONTRACT,
    LENDINGPOOLPROVIDER_ADRESS} from './helper'

const { USER_ADDRESS } = process.env;

const YieldFarm = artifacts.require('./YieldFarm')

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('YieldFarm',([user]) => {
    let yieldFarm

    beforeEach(async () => {
        //deploy farm
        yieldFarm = await YieldFarm.new(DAI_ADDRESS,CDAI_ADDRESS, ADAI_ADDRESS, LENDINGPOOL_ADDRESS,LENDINGPOOLPROVIDER_ADRESS)

        //transfer dai to test user account
        await DAI_CONTRACT().methods
        .transfer(user, ether(10))
        .send({from: LARGE_DAI_ADDRESS})

        await DAI_CONTRACT().methods
        .approve(yieldFarm.address, ether(10))
        .send( {from: user} )
    })

    describe('deployment', () => {
        it('name is correct', async () => {
            let result = await yieldFarm.name()
            result.should.equal('Dai Yield Farm')
        })
        it('dai address is correct', async () => {
            let result = await yieldFarm.daiToken()
            result.should.equal(DAI_ADDRESS)
        })
    })

    describe('deposit Dai', () => {
        let balance
        let amount
        let result

        describe('success', () => {

            beforeEach( async () => {
                amount = ether(.1)
                result = await yieldFarm.depositDai(DAI_ADDRESS,amount, {from: user})
            })

            it('deposits dai to yieldfarm', async () => {
                balance =  await yieldFarm.balanceOf(user)
                balance.toString().should.equal(amount.toString())
            })
            it('emits a Deposit event', async () => {
                const log = result.logs[0]
                log.event.should.equal('Deposit')
                const event = log.args
                event.staker.toString().should.equal(user,'user address is correct')
                event.amount.toString().should.equal(amount.toString(),'value is correct')
                event.balance.toString().should.equal(amount.toString(),'value is correct')

            })
        })
        describe('failure', () => {
            it('reject tokens that are not dai', async () => {
                await yieldFarm.depositDai(ETHER_ADDRESS,amount, {from: user}).should.be.rejectedWith(EVM_REVERT)
            })
            it('insufficient dai amount', async () => {
                await yieldFarm.depositDai(DAI_ADDRESS,ether(1000), {from: user}).should.be.rejectedWith(EVM_REVERT)
            })
        })
    })

    describe('withdrawl Dai', () => {
        let balance
        let amount
        let result
        let withdrawlAmount

        describe('success', () => {

            beforeEach( async () => {
                amount = ether(.1)
                withdrawlAmount = ether(.001)

                result = await yieldFarm.depositDai(DAI_ADDRESS,amount, {from: user})
                result = await yieldFarm.withdrawlDai(DAI_ADDRESS,amount, {from: user})
            })


            it('withdrawls dai from yieldfarm', async () => {             
                balance =  await yieldFarm.balanceOf(user)
                balance.toString().should.equal('0')
            })
            it('emits a Withdrawl event', async () => {
                const log = result.logs[0]
                log.event.should.equal('Withdrawl')
                const event = log.args
                event.staker.toString().should.equal(user,'user address is correct')
                event.amount.toString().should.equal(amount.toString(),'value is correct')
                event.balance.toString().should.equal('0','value is correct')

            })
        })
        describe('failure', () => {
            it('reject tokens that are not dai', async () => {
                await yieldFarm.withdrawlDai(ETHER_ADDRESS,amount, {from: user}).should.be.rejectedWith(EVM_REVERT)
            })
            it('insufficient dai amount', async () => {
                await yieldFarm.withdrawlDai(DAI_ADDRESS,ether(100), {from: user}).should.be.rejectedWith(EVM_REVERT)
            })
        })
    })

})