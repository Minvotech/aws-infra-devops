resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace = var.namespace_cluster-bootstrapping
  set {
    name  = "installCRDs"
    value = "true"  
  }
}

  #values = [file("${path.module}/certmanager/values-cert-manager.yml")]


# resource "null_resource" "apply_SecretCoudFlare" {
#   triggers = {
#     namespace = var.namespace_cluster-bootstrapping
#   }
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/certmanager/secret_cloudflare.yml --namespace ${var.namespace_cluster-bootstrapping}"
#   }
# }