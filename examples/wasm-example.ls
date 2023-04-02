
  { write } = dependency 'Console'
  { new-wasm-instance } = dependency 'Wasm'

  instance = new-wasm-instance 'add.wasm'

  write instance.exports.add 8, 2
