apiVersion: v1
kind: Config
clusters:
- name: aks
  cluster:
    server: ${host}
    certificate-authority-data: ${cluster_ca_certificate}
contexts:
- name: aks
  context:
    cluster: aks
    user: aks-user
current-context: aks
users:
- name: aks-user
  user:
    client-certificate-data: ${client_certificate}
    client-key-data: ${client_key}
