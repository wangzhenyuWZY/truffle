const KAKACard721 = artifacts.require('KAKACard721')

contract('Kaka721 test', async accounts => {
    it("check balance", async () => {
        const kaka721C = await KAKACard721.deployed();
        const balance = await kaka721C.balanceOf.call(accounts[0]);
        for (let i = 0; i < balance; ++i) {
            const tokenId = await kaka721C.tokenOfOwnerByIndex.call(accounts[0], i);
            console.log(tokenId)
        }
        assert.equal(balance, 0);
        assert.equal(balance.valueOf(), 10000);
    });
})