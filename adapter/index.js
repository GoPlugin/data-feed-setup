const { Requester, Validator } = require('@goplugin/external-adapter')
require("dotenv").config();

const customError = (data) => {
  if (data.Response === 'Error') return true
  return false
}

const createRequest = (input, callback) => {

const url = `https://goplugin.apidiscovery.teejlab.com/edsn/api/gateway?endpoint_id=aHBrfib`

var dataString = {"fsyms": `${input.data._fsyms}`, "tsyms": `${input.data._tsyms}`};
const config = {
    url,
    method : "POST",
    data : dataString,
  }

  if (process.env.API_KEY) {
    config.headers = {
      "api-key": process.env.API_KEY
    }
  }
  Requester.request(config, customError)
    .then(response => {
      const res = {
        data: {
         "result": response.data[`${input.data._fsyms}`][`${input.data._tsyms}`].toString()
}
      }
      callback(response.status, Requester.success(input.id, res));
    })
    .catch(error => {
      callback(500, Requester.errored(input.id, error))
    })
}

module.exports.createRequest = createRequest
