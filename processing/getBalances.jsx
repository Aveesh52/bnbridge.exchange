/*
  GET BALANCES:
  1. Load the file with accounts
  2. call getBalance on smart contract
  3. Add all the balances
*/

const config = require('./config')
const eth = require('./helpers/eth.js')
const fs = require('fs');
const async = require('async');

const ERC20_CONTRACT = '0xd379255277e87e3636708a71f7a845a86f8c591d'

loadFile()

function loadFile() {
  var text = fs.readFileSync('/Users/dennis.won/harmony-one/bnbridge.exchange/accounts/harmonyAccounts_final.txt','utf8')
  processFile(text)
}

function processFile(content) {

  let lines = content.split("\r\n")

  lines.map((line) => {

  })

  async.map(lines, (line, callback) => {
    if(line=="") {
      return callback(null, '0')
    }

    let address = line.split(",")[1]

    eth.getERC20Balance(address, ERC20_CONTRACT, (err, res) => {

      if(res == "0") {
        console.log(address)
      }

      callback(err, res)
    })
  }, (err, result) => {
    if(err) {
      console.log(err)
      return
    }

    console.log(result)

    let balance = result.reduce((accumulator, currentValue) => {
      return parseFloat(currentValue) + accumulator
    }, 0)

    console.log(balance)
  })

}

function error(err) {
  console.log(err)
  return
}
