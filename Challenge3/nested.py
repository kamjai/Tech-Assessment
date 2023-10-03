def get_value_from_nested_object(object, key):
  """Returns the value of the given key from the given nested object.

  Args:
    object: The nested object.
    key: The nested key.

  Returns:
    The value of the given key.
  """

  keys = key.split(".")
  current_object = object
  for key in keys:
    if key not in current_object:
      return None
    current_object = current_object[key]
  return current_object

person = {
    "name": "Kamlesh",
    "address": {
        "city": "Bangalore"
    }
}

value = get_value_from_nested_object(person, "address.city")

print(value)
