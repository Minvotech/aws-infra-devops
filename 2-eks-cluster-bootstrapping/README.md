Terraform code for the EKS cluster bootstrapping, which includes the deployment of the Ingress-Kong, Prometheus stack (with Loki and Promtail), and Cert-Manager.

Ingress-Kong:
The code sets up the Ingress-Kong controller, which is a popular open-source API gateway and Kubernetes Ingress controller.
It installs the Ingress-Kong Helm chart and configures the necessary settings, such as the Ingress class, the Kong proxy and admin ports,
This Ingress-Kong setup allows for advanced routing, load balancing, and management of incoming HTTP(S) traffic to the services running in the EKS cluster.
Prometheus Stack:
The code sets up the Prometheus stack, which includes Prometheus, Grafana, Loki, and Promtail.
Prometheus is a popular open-source monitoring and alerting system for Kubernetes and other systems.
Loki is a log aggregation system that works seamlessly with Prometheus, providing centralized logging capabilities.
Promtail is the agent that collects logs from the Kubernetes nodes and forwards them to Loki.
The code configures the Prometheus Helm chart, the Loki Helm chart, and the necessary settings for these components  

This setup allows for comprehensive monitoring, logging, and observability of the applications and infrastructure running in the EKS cluster.
Cert-Manager:
The code sets up the Cert-Manager, which is a Kubernetes add-on that automates the management and issuance of TLS certificates.
Cert-Manager integrates with various certificate authorities, such as Let's Encrypt, to provide automatic certificate provisioning and renewal for the Kubernetes resources.
The code installs the Cert-Manager Helm chart and configures the necessary settings, such as the cluster issuer and the certificate domains.
This setup ensures that the applications running in the EKS cluster can be accessed over secure HTTPS connections, with automatically managed and renewed TLS certificates.
Monitoring and Observability:
The Terraform code provides the necessary information to access the monitoring and observability stack, including the Grafana URL, username, and password.
The Grafana instance is accessible at the URL :

- https://monitor.lzaz.com/
- user : admin 
- pass :  Islam@#@2002

, with the provided admin credentials.
This Grafana instance serves as the central dashboard for visualizing the metrics and logs collected by the Prometheus and Loki components.
Users can explore the various dashboards and panels to monitor the health, performance, and logs of the applications and infrastructure running in the EKS cluster.
Overall, this Terraform code sets up a comprehensive monitoring and observability stack for the EKS cluster, including Ingress-Kong for advanced traffic management, the Prometheus stack for monitoring and logging, and Cert-Manager for automated TLS certificate management. The Grafana instance provides a centralized interface for visualizing and analyzing the collected metrics and logs.
