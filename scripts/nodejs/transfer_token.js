var fs = require('fs');

var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://ethereum.localdomain:8545"));
var eth = web3.eth;

var addresses = fs.readFileSync("addresses.txt", "utf8").toString();
var addressList = addresses.split("\n");

var contract = /* contract address */;
var coinbase = /* contract owner account */;
var password = /* coinbase password */;
var percise  = /* contract support percise */;

if(addressList[addressList.length - 1] == "") {
  addressList.pop();
}

// Unlock cwner account
web3.personal.unlockAccount(coinbase, password);

function gen_hex(address, value) {
  var real_address = address.slice(2);
  var totalLenLen = 64;
  var real_value = web3.toHex(value).slice(2);

  if(real_value.length < totalLen) {
    var padding = "";
    var paddingCount = totalLen-real_value.length;

    while(paddingCount > 0) {
      padding += "0";
      paddingCount--;
    }

    real_value = padding + real_value;
  }

  var hex = "0xa9059cbb000000000000000000000000" + real_address + real_value;
  return hex;
}

// Rand as 10,000
function random(start, end) {
  var base = Math.random();
  if(base == 0) { return random(start, end); }

  var scope = end - start;

  return (start + scope*base) * 10000;
}

addressList.forEach(function(elem){
  if(elem.length != 42) {
     console.log("Error contract address <" + elem + ">");
     return null;
  }

  var value = random(50, 200).toFixed(0);
  console.log("Quantity is " + value);

  var data = {
    from: coinbase,
    to: contract,
    data: gen_hex(elem, value*Math.pow(10, percise))
  };

  console.log(JSON.stringify(data));

  eth.sendTransaction(data,function(err, txhash){
    if(!err) {
      console.log(txhash);
    } else {
      console.log("Error " + err);
    }
  });
});
