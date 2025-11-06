# Add $data in arr $arr with path $path,
# If $data[$key] does not exist
# $path example: ["templating", "list"]
# $key - field name (e.g.: "name")
# $data - data in insert
# Example:
# add_to_array_if_missing_by_key(["templating", "list"]; $k8s_var; "name")
def add_data_to_array_by_key($path; $data; $key):
  getpath($path) as $arr |
  (
    if ($arr | type == "array") and     # Arrays only
       ($arr | map(select(.[$key] == $data[$key])) | length) == 0    # Counting matches in array of dicts
    then
      setpath($path; $arr + [$data])
    else
      .
    end
  );

# Updates $update_key: $update_value in first arr in $path, where .[$match_key] == $match_value.
# Example:
#   update_dict_in_array_by_key(
#     ["templating", "list"];
#     "name"; "k8s_cluster";
#     "query"; "label_values(up{k8s_cluster!=\"\"}, k8s_cluster)"
#   )
def update_dict_in_array_by_key($path; $match_key; $match_value; $update_key; $update_value):
  getpath($path) as $arr |
  (
    if ($arr | type == "array") then
      # Get index of first match
      ($arr | map(.[$match_key] == $match_value) | index(true)) as $idx |
      if $idx != null then
        setpath($path + [$idx, $update_key]; $update_value)
      else
        .
      end
    else
      .
    end
  );
