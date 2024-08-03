resource "helm_release" "kong" {
  name       = "kong"
  repository = "http://charts.konghq.com"
  chart      = "kong"
  #namespace  = "cluster-bootstrapping"
  namespace   =   var.namespace_cluster-bootstrapping  #"cluster-bootstrapping"

  values = [
    file("${path.module}/ingress-kong/values-kong.yml")
  ]
  depends_on = [
   helm_release.prometheus
   #helm_release.cert-manager,
   ]
}

resource "null_resource" "kong-servicemonitor" {
  # Run after helm_release 
  triggers = {
    release = helm_release.kong.id
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/ingress-kong/kong-servicemonitor.yml"
  }
   provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/ingress-kong/KongClusterPlugin-prometheus.yml"
  }
}