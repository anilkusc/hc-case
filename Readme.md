# HC PoC Project

The purpose of this repo is to build an infrastructure with its components. To run the project, you must follow the instructions in this repo. With the help of this repo, necessary components are created in the AWS cloud environment.After apply this repo, specified rules will be defined, configurations will be applied , applications will be able to deployed and development can be continued after the infrastructure is ready.


# Table of contents

1. [HC PoC Project](#hc-poc-project)
    * [Tech Stack](#tech-stack)
    * [Quick Access](#quick-access)
2. [Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Installation](#installation)
    * [Destroying](#destroying)
3. [Components](#components)
    * [Vault](#vault)
    * [Prometheus](#Prometheus)
    * [Ingress](#Prometheus)

## Tech Stack


* [Terraform-HCL(v1.3.9)](https://www.terraform.io/)

  Terraform is one of the most used IaC tools. It has made it easy to create infrastructure with its unique HCL (Hashicorp Configuration Language). Its modular structure, well-documented, well-explained module reference pages and compatibility with all major cloud providers are effective factors in choosing Terraform.

* [AWS(aws-cli/2.9.23)](https://aws.amazon.com/)

  AWS is the widely used cloud service founded by Amazon. All resources used for this demo are hosted on AWS.

* [Helm(v3.11.1)](https://aws.amazon.com/)

  Helm is the best way to find, share, and use software built for Kubernetes.

## Quick Access

1. Sign in to AWS with related user credentials.

   ```sh
    aws configure
   ```

2. Install terraform modules
   ```sh
    terraform init
   ```

3. Apply the terraform configurations.
   ```sh
   terraform apply --auto-approve
   ```

4.  Wait until completed and check if everything is OK :) 

# Getting Started

This section shows how to build project from stract. To start the project, first you need to provide prerequisites. Then follow the instructions in Installation. To destroy the infrastructure, follow the instructions in the Destroying section. You can find information about variables in the Variables section. In the Cautions section, there are warnings that you need to pay attention to.

## Prerequisites

* **Install AWS-cli** :

Aws-cli must be installed on the system. The quick install command for Linux is given below. For other operating systems, you can refer to the  [aws-cli documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) 

  ```sh
  sudo apt update && apt install unzip -y && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && sudo unzip awscliv2.zip && sudo ./aws/install
  ```

* **Install Terraform**:

Terraform must be installed to the system for apply the configurations. <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">terraform documentation </a>.

  ```sh
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install terraform -y
  ```

* **Install Helm** :

Helm must be installed to the system for apply the configurations. <a href="https://helm.sh/docs/intro/install/">helm documentation </a>.

  ```sh
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  ```

## Installation

* **Apply** :

After aws-cli configured you can only init and apply terraform.

  ```sh
  terraform init && terraform apply -auto-approve
  ```

* **Kubectl Access** :

For examine the structure you should get kubectl access

  ```sh
  aws eks update-kubeconfig --region eu-west-1 --name test-eks-cluster
  ```

## Destroying

Delete Infrastructure 
   ```sh
   terraform destroy --auto-approve
   ```

# Components

This section contains information about system components.

### Vault
 
 * Vault is a popular open-source tool for managing secrets and sensitive data in modern software applications. It provides a secure and centralized platform for storing, accessing, and managing secrets such as passwords, API keys, and certificates. Vault uses a range of authentication and authorization methods to ensure that only authorized users and applications can access sensitive data.

  * For adding a secret to vault you can use following commands 
   ```sh
   token=$(kubectl get secrets vault-unseal-keys -o jsonpath={.data.vault-root} | base64 --decode)
   kubectl exec -it vault-0 -- sh -c "export VAULT_SKIP_VERIFY=true && vault login $token && vault kv put secret/demosecret/username USERNAME=admin
   ```

  * You can use that secret in kubernetes config like this
   ```sh
    env:
    - name: AWS_SECRET_ACCESS_KEY
      value: vault:secret/data/demosecret/aws#USERNAME
   ```

   * But you should add following annotations to deployment manifest
   ```sh
      annotations:
        vault.security.banzaicloud.io/vault-addr: "https://vault:8200"
        vault.security.banzaicloud.io/vault-role: "default" 
        vault.security.banzaicloud.io/vault-skip-verify: "true" 
        vault.security.banzaicloud.io/vault-tls-secret: "vault-tls"
        vault.security.banzaicloud.io/vault-agent: "false" 
        vault.security.banzaicloud.io/vault-path: "kubernetes"
   ```

### Prometheus
 
 * Prometheus is a popular open-source monitoring and alerting system that is widely used in modern software applications and cloud infrastructure. It collects and stores metrics from various sources such as servers, applications, and services, and provides a powerful query language and visualization tools for analyzing and visualizing the data. Prometheus supports a wide range of data collection mechanisms, including HTTP endpoints, service discovery, and custom exporters. In this repository prometheus and alertmanager is used together.

  * You can set configs and alerts from ./manifests/prometheus/values.yaml. You can set your prometheus endpoints etc.

### Ingress
 
 * Nginx Ingress is a popular open-source solution for managing external access to Kubernetes services. It provides a flexible and powerful platform for load balancing, SSL termination, and routing traffic to backend services. 
 
 * By default you it should be expose prometheus but you can configure accessing from ./manifests/nginx-ingress/templates/custom-ing.yaml

 * If you can not reach endpoint pls try to update address:
   ```sh
    external_ip=$(kubectl get svc | grep ingress | awk '{print $4}')
    kubectl patch ingress default-ingress --type=json -p='[{"op": "replace", "path": "/spec/rules/0/host", "value": "$external_ip"}]'
   ```

# Further Information


 * https://www.terraform.io/docs/index.html
 * https://docs.aws.amazon.com/
 * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources
 * https://kubernetes.io/docs/home/