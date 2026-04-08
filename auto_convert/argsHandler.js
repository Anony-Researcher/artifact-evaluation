// argsHandler.js
function handleArguments() {
  const numArgs = process.argv.length - 2; // Subtract 2 to exclude "node" and the script file name
  if (numArgs !== 2) {
    console.error('Usage: node auto-convert.js <input-file-path> <output-file-path>');
    process.exit(1);
  }
  
  const filepath = process.argv[2];
  const outputpath = process.argv[3];
  
  return { filepath, outputpath };
}

exports.handleArguments = handleArguments;