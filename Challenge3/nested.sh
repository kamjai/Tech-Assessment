#!/bin/bash

function get_value_from_nested_object() {
  local object=$1
  local key=$2

  # Split the key into an array of keys.
  local keys=(${key//./ })

  # Iterate over the keys and get the value of each key.
  local value=""
  for key in "${keys[@]}"; do
    value="${object[$key]}"
    if [[ ! ${value} ]]; then
      echo "The key '$key' does not exist in the object."
      return 1
    fi

    # If the value is not an object, then we have reached the end of the nested key.
    if [[ ! ${value} =~ '^[[:alpha:]]+$' ]]; then
      break
    fi

    object=${value}
  done

  # Return the value of the last key.
  echo "${value}"
}
