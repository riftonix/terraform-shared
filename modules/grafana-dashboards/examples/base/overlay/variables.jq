def k8s_cluster_var:
  {
    "name": "k8s_cluster",
    "type": "query",
    "label": "DIT K8S Cluster",
    "current": {"text": "k8s-siem", "value": "k8s-siem"},
    "datasource": "$datasource",
    "query": "query_result(kafka_server_replicamanager_leadercount)",
    "regex": "/.*k8s_cluster=\"(k8s-siem|k8s-siemng-prod)/",
    "refresh": 1,
    "includeAll": false,
    "options": []
  };
