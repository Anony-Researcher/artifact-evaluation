const { parse } = require('./parse');
let graphViz = require('graphviz');

async function main() {
    let contractJson = {
      "contractName": "Example",
      // rest of your json data...
  };

try{
 const ast = await parse(contractJson.contractCode);
} catch (error) {
   console.error(error)
}

// Create a new graph
let dot = Graphviz.dot();

dot.addNode("Start", { shape: 'ellipse' });
dot.addEdge('start', "End");

console.log(dot.toString());

main();
}
function parse(code){
  // Your logic here, for example:
    return {
      body:[
        {type:'contract'}
      ]
    }
}

module.exports = main;
