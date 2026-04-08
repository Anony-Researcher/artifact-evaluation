import pandas as pd
import requests
import os
import time
import json

def get_latest_count(file_path):
    try:
        with open(file_path, "r") as file:
            latest_count = int(file.read().strip())
    except FileNotFoundError:
        # If the file doesn't exist, start from count 1
        latest_count = 1
    except ValueError:
        # If the file contains non-integer data, start from count 1
        latest_count = 1
    return latest_count

def update_latest_count(file_path, count):
  with open(file_path, "w") as file:
      file.write(str(count))

def fetch_contract_source_code(contract_address, api_key, output_folder):
  url = f"https://api.etherscan.io/api?module=contract&action=getsourcecode&address={contract_address}&apikey={api_key}"

  try:
      response = requests.get(url)
      response.raise_for_status()  # Raise an exception for HTTP errors

      data = response.json()
      if data["status"] == "1":
          source_code = data["result"][0]["SourceCode"]
          contract_name = data["result"][0]["ContractName"]
          
          # Create the output folder if it doesn't exist
          if not os.path.exists(output_folder):
              os.makedirs(output_folder)

          # Write the source code to a Solidity file
          output_file_path = os.path.join(output_folder, f"{contract_name}.sol")
          with open(output_file_path, "w") as file:
              file.write(source_code)

          print(f"Source code written to {output_file_path}")
      else:
          print(f"Failed to fetch source code for contract at address {contract_address}: {data['message']}")

  except requests.exceptions.RequestException as e:
      print(f"Error during API request for contract at address {contract_address}: {e}")
  except (json.JSONDecodeError, KeyError) as e:
      print(f"Error decoding JSON response or extracting data for contract at address {contract_address}: {e}")
  except OSError as e:
      print(f"Error creating directory or writing file for contract at address {contract_address}: {e}")
  except Exception as e:
      print(f"An unexpected error occurred for contract at address {contract_address}: {e}")

df = pd.read_csv('verified_contracts_etherscan.csv')
count_file_path = "./counter.txt"
latest_count = get_latest_count(count_file_path)
contract_addresses = df.iloc[latest_count:, 1].tolist()  # Get all addresses as list
# Set counter for one iteration
counter = latest_count
print(f"Staring from {counter}")

base_url = 'https://api.etherscan.io/api'
with open('api_key.txt', 'r') as f:
  api_key = f.read().strip() 

for address in contract_addresses:

  fetch_contract_source_code(address, api_key, '../contract_store')
  # Sleep after every 5 calls to avoid API key rate limit
  if counter % 5 == 0:
    time.sleep(1)  # Sleep for 1 second

  counter += 1  # Increment counter after processing the address
  update_latest_count(count_file_path, counter)

print(f"{counter} contracts written to contract store")