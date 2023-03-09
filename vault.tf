resource "helm_release" "vault-operator" {
  name       = "vault-operator"
  repository = "https://kubernetes-charts.banzaicloud.com"
  chart      = "vault-operator"
  namespace  = "default"
}

resource "kubectl_manifest" "rbac" {
  yaml_body = file("${path.module}/manifests/rbac.yaml")
  depends_on = [
    helm_release.vault-operator
  ]
}

resource "kubectl_manifest" "cr" {
  yaml_body = file("${path.module}/manifests/cr.yaml")
  depends_on = [
    helm_release.vault-operator
  ]
}

resource "kubernetes_namespace" "vault-infra" {
  metadata {

    labels = {
      mylabel = "vault-infra"
    }
    name = "vault-infra"
  }
}

resource "helm_release" "vault-secrets-webhook" {
  name       = "vault-secrets-webhook"
  repository = "https://kubernetes-charts.banzaicloud.com"
  chart      = "vault-secrets-webhook"
  namespace  = "vault-infra"
  depends_on = [
    kubernetes_namespace.vault-infra
  ]
}

resource "kubectl_manifest" "vault-test" {
    yaml_body = file("${path.module}/manifests/vault-test.yaml")
    depends_on = [
    helm_release.vault-secrets-webhook
    ]
}