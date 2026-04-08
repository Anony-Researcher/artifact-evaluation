import os
import re
import sys
from solcx import compile_source, install_solc, set_solc_version
from web3 import Web3
from web3.exceptions import ContractLogicError

# Function to connect to the Ethereum node
def connect_to_web3():
    try:
        w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))
        if not w3.is_connected():
            raise ConnectionError("Failed to connect to Ethereum node")
        return w3
    except Exception as e:
        print(f"Error connecting to Ethereum node: {e}")
        return None

# Connect to a local Ethereum node (e.g., Ganache)
w3 = connect_to_web3()
if not w3:
    raise SystemExit("Cannot proceed without an Ethereum node connection.")

# Function to extract pragma version from Solidity file
def extract_pragma_version(source_code):
    match = re.search(r'pragma\s+solidity\s+(\^?\d+\.\d+\.\d+);', source_code)
    if match:
        version = match.group(1)
        # Remove the caret (^) if present
        return version.lstrip('^')
    else:
        raise ValueError("Pragma version not found in Solidity file")

# Function to preprocess Solidity source code
def preprocess_source_code(source_code):
    # Extract multiple SPDX license identifiers
    spdx_identifiers = re.findall(r'^// SPDX-License-Identifier: [^\n]+$', source_code, flags=re.MULTILINE)
    if spdx_identifiers:
        # Combine SPDX license identifiers using "AND" if multiple are found
        unique_identifiers = set(re.sub(r'^// SPDX-License-Identifier: ', '', ident).strip() for ident in spdx_identifiers)
        combined_identifiers = ' AND '.join(unique_identifiers)
        source_code = re.sub(r'^// SPDX-License-Identifier: .+?$', f'// SPDX-License-Identifier: {combined_identifiers}', source_code, flags=re.MULTILINE)
    else:
        # Add a single SPDX license identifier if none found
        source_code = '// SPDX-License-Identifier: MIT\n' + source_code
    return source_code

# Function to read Solidity file and resolve imports
def read_solidity_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    
    base_dir = os.path.dirname(file_path)
    content = preprocess_source_code(content)
    
    # Resolve imports relative to the current file directory
    print(f"\nResolving imports for {base_dir}\n")
    content = resolve_imports(content, base_dir)
    return content

# Function to resolve imports
def resolve_imports(source_code, base_dir):
    import_statements = re.findall(r'import\s+\{\s*[^}]+\s*\}\s+from\s+["\'](.+?)["\'];', source_code)
    print(f"Import Statements: {import_statements}")
    for import_path in import_statements:
        import_path = import_path.replace('\\', '/')
        # Normalize the import path
        full_import_path = os.path.normpath(os.path.join(base_dir, import_path))
        if not os.path.isfile(full_import_path):
            # Try with a subdirectory if not found
            full_import_path = os.path.normpath(os.path.join(base_dir, os.path.dirname(import_path), os.path.basename(import_path)))
        if os.path.isfile(full_import_path):
            # Recursively resolve imports
            import_content = read_solidity_file(full_import_path)
            # Preserve the original import path format in replacement
            source_code = source_code.replace(f'import {{ {import_path} }} from "{import_path}";', f'// import "{{ {import_path} }}" from "{import_path}"\n{import_content}')
        else:
            print(f"Warning: Imported file {import_path} not found in {base_dir}.")
    return source_code

# Function to compile and estimate gas cost for a Solidity file
def get_deployment_cost(sol_file):
    try:
        # Read and resolve Solidity file
        source_code = read_solidity_file(sol_file)
        
        # Extract and set the Solidity version
        solc_version = extract_pragma_version(source_code)
        install_solc(solc_version)
        set_solc_version(solc_version)
    
        # Compile Solidity source code with resolved imports
        print(f"Compiling {sol_file} with Solidity version {solc_version}")
        compiled_sol = compile_source(source_code)
        contract_interface = compiled_sol[list(compiled_sol.keys())[0]]
        bytecode = contract_interface['bin']
        
        # Estimate gas for contract deployment
        gas_estimate = w3.eth.estimate_gas({'data': '0x' + bytecode})
        return gas_estimate
    except ContractLogicError as e:
        print(f"ContractLogicError processing {sol_file}: {e}")
        return None
    except Exception as e:
        print(f"Error processing {sol_file}: {e}")
        return None

# Check for correct number of arguments
if len(sys.argv) != 2:
    print("Usage: python calc_gas_cost.py <directory_path>")
    sys.exit(1)

# Directory containing .sol files
main_dir = sys.argv[1]

# Check if the provided path is a directory
if not os.path.isdir(main_dir):
    print(f"Error: {main_dir} is not a valid directory.")
    sys.exit(1)

# Iterate through each .sol file in the directory
for subdir, _, files in os.walk(main_dir):
    for filename in files:
        if filename.endswith('.sol'):
            print(f"\n\nChecking {filename}\n\n")
            file_path = os.path.join(subdir, filename)
            try:
                gas_cost = get_deployment_cost(file_path)
                if gas_cost is not None:
                    print(f"Contract: {filename} | Gas Cost: {gas_cost} units")
            except Exception as e:
                print(f"Error processing {file_path}: {e}")

print("Gas costs for all contracts printed.")