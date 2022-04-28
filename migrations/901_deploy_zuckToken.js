const ZUCKPLUS = artifacts.require('ZUCKPLUS')

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(ZUCKPLUS)
}