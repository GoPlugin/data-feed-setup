const { Requester, Validator } = require('@goplugin/external-adapter')

const customError = (data) => {
    if (data.Response === 'Error') return true
    return false
}

const createRequest = (input, callback) => {
    const jobRunID = input.id;
    
    console.log("log:::values:::",input);
    
    const params = {
        fsym: input.data._fsysm,
        tsyms: input.data._tsysm,
    }
    const config = {
        url: "https://min-api.cryptocompare.com/data/price",
        params
    }
    Requester.request(config, customError)
        .then(response => {
            const res = {
              data: {
                "result": response.data.USD.toString()
              }
            }
            callback(response.status, {jobRunID, ...res});
        })
        .catch(error => {
            callback(500, Requester.errored(jobRunID, error))
        })
}

module.exports.createRequest = createRequest