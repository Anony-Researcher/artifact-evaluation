const fs = require("fs");
const path = require('path');
const prettier = require("prettier");
const parser = require("@solidity-parser/parser");
const { handleArguments } = require('./argsHandler');
const { exit } = require("process");
const {filepath, outputpath} = handleArguments()
const LIB_NAME = "Test";
 
var CONTRACT_NAME, START;
var dirName;
var STRUCT_VARIABLES = "";
var constants = "";
var usingDeclaration = "";
var struct_checker = [];
let function_names = [];
let allModifiers = "";
var declare_checker = [];
var parent_contracts = [];
var eventMap = new Map();
var INIT_VALUES = new Map();
var inheritanceMap = new Map();
 
let V;
let adjList = new Map();
let visited_array_functions = new Map();
let functions_information = new Map();
let functionToParent = new Map();
let modifierToParent = new Map();
 
function getUniqueDirName(outputPath, contractName) {
    const dirName = path.join(outputPath, `${contractName}facets`);
 
    if (!fs.existsSync(dirName)) {
        return dirName;
    }
 
    let count = 1;
    let newDirName = path.join(outputPath, `${contractName}facets${count}`);
    while (fs.existsSync(newDirName)) {
        count++;
        newDirName = path.join(outputPath, `${contractName}facets${count}`);
    }
 
    return newDirName;
}
 
// Adds an edge to an undirected graph
function addEdge(src, dest) {
	// Add an edge from src to dest.
	if (!adjList.has(src)) {
		adjList.set(src, []);
	}
	
	if (!adjList.has(dest)) {
		adjList.set(dest, []);
	}
	
	// Add the caller function to the adjacency list of the called function
	adjList.get(src).push(dest);
	adjList.get(dest).push(src);
}
 
function DFSUtil(key,reached_functions) {
	// Mark the current node as visited and print it
	visited_array_functions.set(key,true);
	reached_functions.push(key)
	// Recur for all the vertices
	// adjacent to this vertex
	for (let x = 0; x < adjList.get(key).length; x++) {
		if (!visited_array_functions.get(adjList.get(key)[x]))
			DFSUtil(adjList.get(key)[x], reached_functions);
	}
}
 
function connectedComponents() {	
	for (let [key, value] of visited_array_functions) {
		if (value == false) {
			var reached_functions = []
			DFSUtil(key, reached_functions);
			console.log(`Key: ${key}\nReached Functions: ${reached_functions}`);
			generateFacetFiles(reached_functions)
		}
	}
}
 
function detectContractType(sourceCode, contractName) {
    const contractRegex = new RegExp(`contract\\s+${contractName}`);
    const abstractRegex = new RegExp(`abstract\\s+contract\\s+${contractName}`);
    const interfaceRegex = new RegExp(`interface\\s+${contractName}`);
    
    if (abstractRegex.test(sourceCode)) {
        return 'abstract contract';
    } else if (interfaceRegex.test(sourceCode)) {
        return 'interface';
    } else if (contractRegex.test(sourceCode)) {
        return 'contract';
    } else {
        return 'unknown';
    }
}
 
function getCalledFunctionNames(jsCode) {
    // Regular expression to match function calls
    const functionCallRegex = /\b([a-zA-Z_]\w*)\s*\(/g;
 
    // Find all matches for function calls
    let matches = [...jsCode.matchAll(functionCallRegex)].map(match => match[1]);
 
    // Remove duplicates by converting to a Set, then return as an array
    return [...new Set(matches)];
}
 
function buildInheritanceMap(filepath) {
    const srcCode = fs.readFileSync(filepath, 'utf8');
    const inheritanceMap = {};
    const ast = parser.parse(srcCode, { tolerant: true });
 
    parser.visit(ast, {
        ContractDefinition(node) {
            inheritanceMap[node.name] = node.baseContracts.map(base => base.baseName.namePath);
        }
    });
 
    return inheritanceMap;
}
 
function topologicalSort(facetParents, inheritanceMap) {
    const sorted = [];
    const visited = new Set();
    const temp = new Set();
 
    function visit(node) {
        if (temp.has(node)) {
            throw new Error(`Cyclic inheritance detected involving ${node}`);
        }
        if (!visited.has(node)) {
            temp.add(node);
            const parents = inheritanceMap[node] || [];
            for (const parent of parents) {
                if (facetParents.has(parent)) {
                    visit(parent);
                }
            }
            temp.delete(node);
            visited.add(node);
            sorted.push(node);
        }
    }
 
    for (const parent of facetParents) {
        visit(parent);
    }
 
    return sorted;
}
 
function generateFacetFiles(function_array) {
	var srcCode = fs.readFileSync(filepath, "utf8");
	srcCode = prettier.format(srcCode, {
		parser: "solidity-parse",
	});
 
	// Define a regex to match all lines up to the first pragma statement
	const pragmaRegex = /^.*pragma.*$/m;
	const match = srcCode.match(pragmaRegex);
 
	let licenseAndPragma = '';
	if (match) {
		// Get lines from the start up to the first pragma
		const endIndex = match.index + match[0].length;
		licenseAndPragma = srcCode.substring(0, endIndex).trim();
	}
	let facetParents = new Set();
	//collect all function code from entire connected component
	let allEvents = '', allFunctionCode= '';
	for (let index = 0; index < function_array.length; index++) {
		console.log(`${function_array[0]}Facet contains ${function_array[index]}`);
		if(functionToParent.has(function_array[index])) {
			facetParents.add(functionToParent.get(function_array[index]));
		}
		allEvents += functions_information.get(function_array[index]).events
		allFunctionCode += functions_information.get(function_array[index]).rePlacedCode
	}
	console.log('\n');
 
	// Arrays to store abstract contracts, interfaces, and regular contracts
	let abstractContracts = [];
	let interfaces = [];
	let contracts = [];
 
	// Classify parent contracts
	for (let parent of parent_contracts) {
		let contractType = detectContractType(srcCode, parent);
		if (contractType === 'abstract contract') {
			abstractContracts.push(parent);
		} else if (contractType === 'interface') {
			interfaces.push(parent);
		} else if (contractType === 'contract') {
			contracts.push(parent);
			facetParents.add(parent);
		}
	}
 
	//since we may have function calls from abstract contract
	for (let code of [allEvents, allModifiers, allFunctionCode]) {
		const calledFunctions = getCalledFunctionNames(code);
		for(let calledFunction of calledFunctions) {
			if(functionToParent.has(calledFunction)) {
				facetParents.add(functionToParent.get(calledFunction));
			}
		}
		console.log(`Called Functions for ${function_array[0]}Facet: ${calledFunctions}`);
	}
 
	console.log("Abstract Contracts: ", abstractContracts);
	console.log("Interfaces: ", interfaces);
	console.log("Contracts: ", contracts);
 
	console.log(`Facet Parents for ${function_array[0]}: ${Array.from(facetParents)}`);
	console.log("Before Sorting: ", Array.from(facetParents));
	var sortedList = topologicalSort(facetParents, inheritanceMap);
	console.log("After Soring: ", Array.from(sortedList));
 
	const isClause = Array.from(facetParents).length > 0 ? `is ${Array.from(sortedList).join(', ')}` : '';
	console.log("isClause: ", isClause);
 
	// console.log(`${function_array[0]}`);
	// console.log(`${licenseAndPragma}`);
	// console.log('\n\n');
	const fileCode = `
	${licenseAndPragma}
	import "./${LIB_NAME}Lib.sol";
    contract ${function_array[0]}Facet ${isClause} {
      ${usingDeclaration}
	  ${allModifiers}
      ${allEvents}
      ${allFunctionCode}
    } 
  `;
	const fileName = `${dirName}/${function_array[0]}Facet.sol`;
	console.log(`Code for ${fileName} is:\n${fileCode}`);
	const formattedCode = prettier.format(fileCode, {
		parser: "solidity-parse",
	});
	fs.writeFileSync(fileName, formattedCode);
}
 
 
function distributeFunctions() {
	var sourceCode = fs.readFileSync(filepath, "utf8");
	sourceCode = prettier.format(sourceCode, {
		parser: "solidity-parse",
	});
	// Parse Solidity code into an AST
	CONTRACT_NAME = path.basename(filepath).replace('.sol', '');
	
	var ast = parser.parse(sourceCode, { loc: true });
	for (let i = 0; i < ast.children.length; i++) {
		const node = ast.children[i];
		if (node.type === "ContractDefinition" && node.kind === "contract" && node.name == CONTRACT_NAME) {
			CONTRACT_NAME = node.name;
			START = node.loc.start.line;
			for (let j =0; j < node.subNodes.length; j++) {
				if (node.subNodes[j].type === "UsingForDeclaration") {
					const start = node.subNodes[j].loc.start.line;
					const end = node.subNodes[j].loc.end.line;
					const lineOfCode = sourceCode
						.split("\n")
						.slice(start - 1, end)
						.join("\n");
					usingDeclaration += `${lineOfCode.substring(node.subNodes[j].loc.start.column)}\n`;
				}
			}
			for(let j = 0; j < node.baseContracts.length; j++) {
				// console.log(`Base Contract for ${node.name}: ${node.baseContracts[j].baseName.namePath}`)
				parent_contracts.push(node.baseContracts[j].baseName.namePath);
			}
		}
	}
 
	// console.log(`Contract Name: ${CONTRACT_NAME}`);
 
	dirName = getUniqueDirName(outputpath, CONTRACT_NAME);
 
	// console.log(`MAKING DIRECTORY ${dirName}`);
	fs.mkdir(`${dirName}`, { recursive: true },err=>{
		if (err) throw err;
	});
 
	
	// Traverse AST to identify function declarations
 
	//find all state variables
	ast.children.forEach((node) => {
		if(node.type == "ContractDefinition" && node.name == CONTRACT_NAME) {
			node.subNodes?.forEach((subNode) => {
				if (subNode.type == "StateVariableDeclaration") {
					var varType;
					typeName = subNode.variables[0].typeName;
					if (typeName.type == "ArrayTypeName") {
						varType =
							typeName.baseTypeName.name +
							`[${
								typeName.length != null
									? typeName.length.number
									: ""
							}]`;
					} else if (typeName.type == "Mapping") {
 
						num_mappings = 1;
						varType =
							"mapping("
 
						while (typeName.valueType.type == "Mapping") {
							varType += typeName.keyType.name +
								"=> mapping(";
							typeName = typeName.valueType;
							num_mappings += 1;
						}
 
						varType += typeName.keyType.name + " => " + typeName.valueType.name;
						varType += ")".repeat(num_mappings);
					} else if (typeName.type == "UserDefinedTypeName") {
						varType = typeName.namePath;
					} else {
						varType = typeName.name;
					}
					const varName = subNode.variables[0].name;
	
					if (subNode.variables[0].expression) {
						const start = subNode.loc.start.line;
						const end = subNode.loc.end.line;
						const lineOfCode = sourceCode
							.split("\n")
							.slice(start - 1, end)
							.join("\n");
						var index = 0;
						let currentChar = lineOfCode[index];
						while (currentChar !== ";") {
							if (currentChar === "=") {
								INIT_VALUES.set(varName, [
									lineOfCode.substring(index, lineOfCode.length),
									0,
								]);
								break;
							}
							index++;
							currentChar = lineOfCode[index];
						}
					}
					if (subNode.variables[0].isDeclaredConst) {
						constants += `${varType} constant ${varName}`;
						if (INIT_VALUES.has(varName)) {
							constants += INIT_VALUES.get(varName)[0];
						}
						else constants += ";";
						constants += "\n";
					}
					else if (typeName.stateMutability == "payable") {
						STRUCT_VARIABLES += `${varType} payable ${varName};\n`;
						struct_checker.push(varName);
					} else {
						STRUCT_VARIABLES += `${varType} ${varName};\n`;
						struct_checker.push(varName);
					}
				} else if (subNode.type == "EventDefinition") {
					if (!eventMap.has(subNode.name)) {
						eventMap.set(subNode.name, []);
					}
					eventMap.get(subNode.name).push(subNode);
				}
			});
		}
	});	
 
	if (STRUCT_VARIABLES == "") {
		console.log(
			"As there are no state variables you can directly use the contract, state is not vulnerable"
		);
		return;
	}
 
	inheritanceMap = buildInheritanceMap(filepath);
	console.log("Inheritance Map Created: ", inheritanceMap);
 
	let implementedFunctions = new Set();
    let inheritedFunctions = new Map();
	let inheritedModifiers = new Map();
 
    // Collect function declarations from the current contract
    let functionDeclarations = new Set();
    ast.children.forEach(node => {
        if (node.type === "ContractDefinition" && node.name === CONTRACT_NAME) {
            node.subNodes.forEach(subNode => {
                if (subNode.type === "FunctionDefinition" && subNode.isConstructor === false) {
                    functionDeclarations.add(subNode);
                }
            });
        }
    });
 
    // Create maps to store inherited functions and modifiers
    parent_contracts.forEach(parentContract => {
        let parentFunctions = new Set();
		let parentModifiers = new Set();
        const parentAst = getParentContractAst(ast, parentContract);
        parentAst.forEach(node => {
            if (node.type === "ContractDefinition" && node.name === parentContract) {
                node.subNodes.forEach(subNode => {
                    if (subNode.type === "FunctionDefinition" && subNode.isConstructor === false) {
                        parentFunctions.add(subNode.name);
						functionToParent.set(subNode.name, parentContract);
                    }
					else if(subNode.type === "ModifierDefinition") {
						parentModifiers.add(subNode.name);
						modifierToParent.set(subNode.name, parentContract);
					}
                });
            }
        });
        inheritedFunctions.set(parentContract, parentFunctions);
		inheritedModifiers.set(parentContract, parentModifiers);
    });
 
	console.log("Func to Parent: ", functionToParent);
 
    // Determine which functions from the current contract are inherited
    let inheritedFunctionsInContract = new Set();
    functionDeclarations.forEach(fn => {
        for (let [_, parentFunctions] of inheritedFunctions) {
            if (parentFunctions.has(fn.name)) {
                inheritedFunctionsInContract.add(fn.name);
                break;
            }
        }
 
		for (let [_, parentModifiers] of inheritedModifiers) {
			for (let modifier of fn.modifiers) {
				if (parentModifiers.has(modifier.name)) {
					console.log(`${fn.name} added to inherited functions because it has modifier ${modifier.name}`);
					inheritedFunctionsInContract.add(fn.name);
					break;
				}
			}
        }
    });
 
	console.log("inheritedFunctions: ", inheritedFunctions);
	console.log("inheritedFunctionsInContract: ", inheritedFunctionsInContract);
 
    // console.log(`Inherited Functions in ${CONTRACT_NAME}: ${Array.from(inheritedFunctionsInContract).join(", ")}`);
	// console.log("Adding Edges...")
	addEdgesForAbstractImplementations(inheritedFunctionsInContract)
 
	// console.log("Finished adding edges for abstract implementations");
	
	//Struct declarations (currently)
	var declrations = "";
	ast.children.forEach((node) => {
		if(node.type == "ContractDefinition" && node.name == CONTRACT_NAME) {
			node.subNodes?.forEach((subNode) => {
				if (
					subNode.type == "StructDefinition" ||
					subNode.type == "EnumDefinition"
				) {
					// struct_checker.push(subNode.name);
					const start = subNode.loc.start.line;
					const end = subNode.loc.end.line;
					var splitArray = sourceCode.split("\n");
					const vassr = splitArray.slice(start - 1, end).join("\n");
					declrations += `${vassr}`;
					declare_checker.push(subNode.name);
				}
			});
		}
	});
 
	//generate library file
 
	generateLibraryFile(sourceCode,declrations)
	
	//functions
	//first find the name of all defined functions such that they can be imported in a facet properly
 
	ast.children.forEach((node) => {
		if (node.type === "ContractDefinition" && node.name == CONTRACT_NAME) {
			node.subNodes.forEach((subNode) => {
				if (
					subNode.type === "FunctionDefinition" &&
					subNode.isConstructor == false
				) {
					function_names.push(subNode.name);
				}
			});
		}
	});
 
	
	ast.children.forEach((node) => {
		if (node.type === "ContractDefinition" && node.name == CONTRACT_NAME) {
			node.subNodes.forEach((subNode) => {
				if (
					subNode.type === "FunctionDefinition" &&
					subNode.isConstructor == false
				) {
					const fileName = `${CONTRACT_NAME}facets/${subNode.name}Facet.sol`;
					const fileContents = generateFileContents(
						subNode,
						sourceCode
					);
					// console.log("File contents are:\n", fileContents);
					functions_information.set(subNode.name,fileContents);
					//make this function visited = false in visited map
					// TODO: This will end up ignoring receive() and fallback() functions if defined as their name is null
					if(subNode.name != null) visited_array_functions.set(subNode.name,false) ;
				}
				else if(subNode.type === "ModifierDefinition") {
					const fileContents = generateFileContents(subNode, sourceCode);
					allModifiers += `${fileContents.rePlacedCode}\n`;
				}
			});
		}
	});
 
	// console.log("Doing connected components now...");
 
	//resolve the graph of functions to generate facet files
	connectedComponents()
 
	// constructor file;
	// ast.children.forEach((node) => {
	// 	if (node.type === "ContractDefinition") {
	// 		node.subNodes.forEach((subNode) => {
	// 			if (
	// 				subNode.type === "FunctionDefinition" &&
	// 				subNode.isConstructor == true
	// 			) {
	// 				const fileContents = generateFileContents(
	// 					subNode,
	// 					sourceCode
	// 				);
	// 				// console.log(subNode)
	// 				const formattedCode = prettier.format(fileContents, {
	// 					parser: "solidity-parse",
	// 				});
	// 				fs.writeFileSync(
	// 					`${CONTRACT_NAME}facets/${CONTRACT_NAME}Facet.sol`,
	// 					formattedCode
	// 				);
	// 				// var sourceCodeDiamond = fs.readFileSync("Diamond.sol", "utf8");
	// 				// sourceCodeDiamond = prettier.format(sourceCodeDiamond, {
	// 				// 	parser: "solidity-parse",
	// 				// });
	// 				// // Parse Solidity code into an AST
	// 				// var astDiamond = parser.parse(sourceCodeDiamond, { loc: true });
					
 
	// 			}
	// 		});
	// 	}
	// });
}
 
function addEdgesForAbstractImplementations(inheritedFunctionsInContract) {
    // Loop through each function in the inheritedFunctionsInContract array
	const functionsArray = Array.from(inheritedFunctionsInContract);
	// console.log(inheritedFunctionsInContract);
    for (let i = 1; i < functionsArray.length; i++) {
        // Get the current and previous function names
        const currentFunctionName = functionsArray[i];
        const previousFunctionName = functionsArray[i - 1];
 
        // Add an edge between the previous function and the current function
		console.log(`Adding edge between inherited functions ${previousFunctionName.name} and ${currentFunctionName.name}`)
        addEdge(previousFunctionName, currentFunctionName);
    }
}
 
function getParentContractAst(ast, parentContractName) {
    let parentContractAst = [];
    ast.children.forEach(node => {
        if (node.type === "ContractDefinition" && parentContractName === node.name) {
            parentContractAst.push(node);
        }
    });
    return parentContractAst;
}
 
function generateFileContents(node, sourceCode) {
	// Generate contents of new file based on function declaration node
	const start = node.loc.start.line;
	const end = node.loc.end.line;
	var splitArray = sourceCode.split("\n");
	const functionCode = splitArray.slice(start - 1, end).join("\n");
	var diamondStorageImportStatement = `${LIB_NAME}Lib.${LIB_NAME}Storage storage ds = ${LIB_NAME}Lib.diamondStorage();`;
	var isImportRequiredFlag = 0;
 
	const structRegExp = new RegExp(
		"\\b(" + struct_checker.join("|") + ")\\b",
		"g"
	);
	const structRegExpDeclarations = new RegExp(
		"\\b(" + declare_checker.join("|") + ")\\b",
		"g"
	);
	var rePlacedCode = "";
 
	// avoid matching empty regex
	if (declare_checker.length > 0) {
		rePlacedCode += functionCode
			.replace(structRegExp, (match) => {
				isImportRequiredFlag = 1;
				return `ds.${match}`;
			})
			.replace(structRegExpDeclarations, (match) => {
				return `${LIB_NAME}Lib.${match}`;
			});
	} else {
		rePlacedCode += functionCode.replace(structRegExp, (match) => {
			isImportRequiredFlag = 1;
			return `ds.${match}`;
		});
	}
 
	if (node.name == null) {
		var collectedHere = "";
 
		for (let [key, value] of INIT_VALUES) {
			if (value[1] == 0) {
				collectedHere += `${key} ${value[0]}`;
				value[1] = 1;
			}
		}
 
		var filtered = "";
		filtered += collectedHere.replace(structRegExp, (match) => {
			isImportRequiredFlag = 1;
			return `ds.${match}`;
		});
 
		rePlacedCode =
			rePlacedCode.slice(0, rePlacedCode.indexOf("{") + 1) +
			"\n" +
			filtered +
			rePlacedCode.slice(rePlacedCode.indexOf("{") + 1);
	}
 
	if (isImportRequiredFlag == 1) {
		const index = rePlacedCode.indexOf("{");
		rePlacedCode =
			rePlacedCode.slice(0, index + 1) +
			"\n" +
			diamondStorageImportStatement +
			rePlacedCode.slice(index + 1);
	}
	var events = "";
	const emitRegExp = /emit\s+([a-zA-Z0-9_]+)\s*\((.*?)\)\s*;/g;
	var visited = new Map();
	let emitMatch;
	while ((emitMatch = emitRegExp.exec(rePlacedCode)) !== null) {
		const eventName = emitMatch[1];
		if (visited.get(eventName) != true) {
			visited.set(eventName, true);
			const matchingEvents = eventMap.get(eventName) || [];
			// If there are matching events, add them to the events variable
			if (matchingEvents.length > 0) {
				matchingEvents.forEach((event) => {
					const startLine = event.loc.start.line;
					const endLine = event.loc.end.line;
					const eventCode = sourceCode
						.split("\n")
						.slice(startLine - 1, endLine)
						.join("\n");
					events += eventCode;
				});
			}
		}
	}
	// function call regex
	const functionCallPattern = /([a-zA-Z_]\w*)\s*\(/g;
 
	// Extract all function calls from the source code
	const functionCalls = [];
	let match;
	while ((match = functionCallPattern.exec(functionCode)) !== null) {
		const functionName = match[1];
		functionCalls.push(functionName);
	}
 
	//remove name of itself
	functionCalls.splice(0,1);
 
	
	functionCalls.forEach((element) => {
		if (function_names.includes(element)) {
			if(node.name!=null){
				addEdge(node.name,element)
				// console.log(`Added edge between ${node.name} and ${element}`);
			}			
		}
	});
	//if function does not have any dependecies, add it as an empty array
 
	if(!adjList.has(node.name)){
		adjList.set(node.name,[])
	}
		
	return {
		events,
		rePlacedCode		
	}
 
    ;
}
 
function generateLibraryFile(sourceCode,declrations){
	// create library
	const libCode = `
	${sourceCode
			.split("\n")
			.slice(0, START - 1)
			.join("\n")}
			
	${constants}
	library ${LIB_NAME}Lib {
 
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.${LIB_NAME}.storage");
    ${declrations}
    
    struct ${LIB_NAME}Storage {		
          ${STRUCT_VARIABLES}
    }
 
    function diamondStorage() internal pure returns (${LIB_NAME}Storage storage ds) {
      bytes32 position = DIAMOND_STORAGE_POSITION;
          assembly {
              ds.slot := position
          }
      }
    }`;
	const formattedCode = prettier.format(libCode, {
		parser: "solidity-parse",
	});
	fs.writeFileSync(`${dirName}/${LIB_NAME}Lib.sol`, formattedCode);
}

distributeFunctions();