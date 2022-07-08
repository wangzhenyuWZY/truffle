const ZuckPool = artifacts.require('ZuckPool')

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(ZuckPool)
}