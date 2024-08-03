resource "null_resource" "app1_crds" {
  triggers = {
    cluster_name     = var.cluster_name
  }
  depends_on = [helm_release.loki]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/app1-cm.yml --namespace apps-prod "
    
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/app1-svc.yml --namespace apps-prod"
 
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/app1-sec.yml --namespace apps-prod"
    
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/app1-ing.yml --namespace apps-prod"
    
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/app1-deploy.yml --namespace apps-prod"
    }
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/app1-hpa.yml --namespace apps-prod"
  }


}