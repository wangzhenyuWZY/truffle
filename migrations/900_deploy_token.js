const AETSN = artifacts.require('AETSNToken')

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(AETSN)
}