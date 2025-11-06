# Function to replace default cluster variable to k8s_cluster in panels block, because of crazy ifrastructure team
# Modifying path: panels[].targets[].expr
# Function generated via qwen
def patch_cluster_to_k8s_cluster:
  (.panels // []) as $panels |           # If .panels == null then replace to []
  if ($panels | type == "array") then
    .panels |= (
        (. // [])
        | map(
            .targets |= (
            (. // [])
            | map(
                select(.expr)
                | .expr |= gsub("cluster=\\\"\\$cluster\\\""; "k8s_cluster=\"$k8s_cluster\"")
                )
            )
        )
    )
  else
    .
  end;