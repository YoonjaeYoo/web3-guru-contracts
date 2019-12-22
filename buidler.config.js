const {usePlugin} = require("@nomiclabs/buidler/config");
const waffleDefaultAccounts = require("ethereum-waffle/dist/config/defaultAccounts").default;

usePlugin("@nomiclabs/buidler-ethers");

module.exports = {
    networks: {
        buidlerevm: {
            accounts: waffleDefaultAccounts.map(acc => ({
                balance: acc.balance,
                privateKey: acc.secretKey
            }))
        }
    },
    solc: {
        version: "0.5.11",
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
};
