const Web3 = require("web3");

const web3 = new Web3();

function signParams(itemIds, address, adminPrivateKey) {
  const publicKey = address;

  const account = web3.eth.accounts.privateKeyToAccount(adminPrivateKey);

  const itemsBufferArray = itemIds.map((x) =>
    Buffer.from(x.toString(16).padStart(64, 0), "hex")
  );

  const finalBuffer = Buffer.concat([
    Uint8Array.from(Buffer.from(publicKey.slice(2), "hex")),
    ...itemsBufferArray,
  ]);

  const dataHash = web3.utils.sha3(finalBuffer);

  return account.sign(dataHash);
}

signParams(
  [1, 2, 3],
  "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
  process.env.PRIVATE_KEY
);

// 0x5395b52cd5641cb7ef2b18739f390fa9d02a4b2325d0f5836a18e5596ba4335e
// 0x5395b52cd5641cb7ef2b18739f390fa9d02a4b2325d0f5836a18e5596ba4335e

// 0xA50DDAC0918854A3BFDDDa0013B11cc9Ef4E02C3
// 0xA50DDAC0918854A3BFDDDa0013B11cc9Ef4E02C3

// 0x5b38da6a701c568545dcfcb03fcb875f56beddc4000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003

// 0xA50DDAC0918854A3BFDDDa0013B11cc9Ef4E02C3
