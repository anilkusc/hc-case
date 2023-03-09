resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  chart      = "./manifests/nginx-ingress"
  depends_on = [module.eks]
}