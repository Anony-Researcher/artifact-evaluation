import os

# Specify the directory path containing the files
directory = '../contract_store'
counter_file = 'diamond_counter.txt'

# Function to read and update the diamond counter
def update_diamond_counter():
    counter = 0

    # Check if the counter file exists
    if os.path.exists(counter_file):
        # Read the counter from the file
        with open(counter_file, 'r') as file:
            counter = int(file.read().strip())

    return counter

# Get the initial diamond counter
diamond_count = update_diamond_counter()

# Get a list of files in the directory
files_to_process = sorted(os.listdir(directory))

# Get the index from the diamond counter file
index = diamond_count

# Iterate through each file starting from the index
for i in range(index, len(files_to_process)):
    filename = files_to_process[i]
    # Check if the file is a regular file (not a directory)
    if os.path.isfile(os.path.join(directory, filename)):
        try:
            # Construct the command to be executed
            command = f'node ../auto_convert/auto-convert.js {os.path.join(directory, filename)} /home/user/auto-diamond/diamond_store'

            # Execute the command using os.system
            exit_code = os.system(command)

            # Check if the command executed successfully (exit code 0)
            if exit_code == 0:
                # Update the diamond counter
                diamond_count += 1
                # Write the updated counter back to the file
                with open(counter_file, 'w') as file:
                    file.write(str(diamond_count))
                print(f"Contract {filename} converted to diamond. Total diamonds: {diamond_count}")
            else:
                print(f"Error converting file '{filename}': Command execution failed")
        except Exception as e:
            print(f"Error converting file '{filename}': {e}")