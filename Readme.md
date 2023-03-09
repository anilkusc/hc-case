terraform init

terraform apply -auto-approve

aws eks update-kubeconfig --region eu-west-1 --name test-eks-cluster

token=$(kubectl get secrets vault-unseal-keys -o jsonpath={.data.vault-root} | base64 --decode)

kubectl exec -it vault-0 -- sh -c "export VAULT_SKIP_VERIFY=true && vault login $token && vault kv put secret/demosecret/username USERNAME=admin && vault kv put secret/demosecret/password PASSWORD=admin"