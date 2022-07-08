const StatueOfLiberty = artifacts.require('StatueOfLiberty')

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(StatueOfLiberty)
}