#!/bin/bash

# Get running container IDs
container_ids=$(docker ps --format "{{.ID}}")

# Create or truncate the output file
output_file="docker_containers_ips.txt"
> $output_file

# Iterate through each container
for container_id in $container_ids; do
    # Get container name
    container_name=$(docker inspect --format '{{.Name}}' $container_id | cut -d "/" -f 2)

    # Get container IP address
    container_ip=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_id)

    # Write to output file
    echo "Container Name: $container_name, IP Address: $container_ip" >> $output_file
done

echo "Output written to $output_file"

