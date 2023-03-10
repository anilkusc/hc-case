resource "helm_release" "vault-operator" {
  name       = "vault-operator"
  chart      = "./manifests/vault-operator"
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "vault-infra" {
  metadata {

    labels = {
      mylabel = "vault-infra"
    }
    name = "vault-infra"
  }
  depends_on = [helm_release.vault-operator]
}

resource "helm_release" "vault-secrets-webhook" {
  name       = "vault-secrets-webhook"
  repository = "https://kubernetes-charts.banzaicloud.com"
  chart      = "vault-secrets-webhook"
  namespace  = "vault-infra"
  depends_on = [kubernetes_namespace.vault-infra]
}

resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  chart      = "./manifests/nginx-ingress"
  depends_on = [module.eks]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "./manifests/prometheus"
  depends_on = [module.eks]
}