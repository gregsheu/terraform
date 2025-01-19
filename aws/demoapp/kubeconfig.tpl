
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${certificate_authority}
    server: ${endpoint}
  name: ${arn}
contexts:
- context:
    cluster: ${arn}
    user: ${arn}
  name: ${arn}
current-context: ${arn}
kind: Config
preferences: {}
users:
- name: ${arn}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - us-east-2
      - eks
      - get-token
      - --cluster-name
      - ${cluster_name}
      - --output
      - json
      command: aws
      env:
      - name: AWS_PROFILE
        value: greg
