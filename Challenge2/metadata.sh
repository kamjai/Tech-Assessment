#!/bin/bash

# Get the instance name from the user.
instance_name=$1
zone=$2

# Query the instance metadata.
gcloud compute instances describe $instance_name --zone $zone --format="json(metadata)" > metadata.json

# Print the JSON formatted metadata to the console.
cat metadata.json
