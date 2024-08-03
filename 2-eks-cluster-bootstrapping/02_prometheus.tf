resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace_monitoring

  values = [
    file("${path.module}/prometheus/values-kube-prometheus.yml")
  ]
  depends_on = [helm_release.cert-manager]
}

resource "null_resource" "promtail-setup" {
  # Run after helm_release 
  triggers = {
    release = helm_release.prometheus.id
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/prometheus/promtail/promtail-setup.yml"
  }
}