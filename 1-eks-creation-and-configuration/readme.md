
### versions TODO -> your should lock these versions
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Finding latest version of hashicorp/null...
- Reusing previous version of hashicorp/kubernetes from the dependency lock file
- Reusing previous version of hashicorp/tls from the dependency lock file
- Using previously-installed hashicorp/aws v4.64.0
- Installing hashicorp/null v3.2.1...
- Installed hashicorp/null v3.2.1 (signed by HashiCorp)
- Using previously-installed hashicorp/kubernetes v2.22.0
- Using previously-installed hashicorp/tls v4.0.4

===== /
- terraform init -migrate-state 
- terraform init -reconfigure
- terraform plan
- terraform apply -auto-approve

  ==================== :
  # [ 1-eks-creation-and-configuration : ]
  
 description of the Terraform code in the GitHub repository for creating a new VPC and deploying an EKS cluster with a node group:

1. VPC Creation:
The code starts by creating a new VPC using the aws_vpc resource. It defines the CIDR block for the VPC and enables DNS hostnames and DNS support. This VPC will be the foundation for hosting the EKS cluster.

2. Public and Private Subnets:
The code then creates public and private subnets within the VPC. The public subnets are used for the EKS control plane, while the private subnets are used for the worker nodes. The public subnets are configured with internet gateways and route tables to allow internet access, while the private subnets use a NAT gateway for outbound internet connectivity.

3. EKS Cluster Creation:
The next step is to create the EKS cluster using the aws_eks_cluster resource. This resource defines the cluster name, version, and the role that will be used to manage the cluster. The cluster is associated with the VPC created earlier, and the control plane is placed in the public subnets.

4. EKS Node Group Creation:
To provide worker nodes for the EKS cluster, the code creates an EKS node group using the aws_eks_node_group resource. This resource defines the node group name, the cluster it belongs to, the instance type, and the desired number of nodes. The node group is placed in the private subnets of the VPC.

5. IAM Roles and Policies:
To enable the necessary permissions for the EKS cluster and node group, the code creates several IAM resources:

aws_iam_role: Defines the IAM roles for the EKS cluster and node group.
aws_iam_role_policy_attachment: Attaches the required IAM policies to the respective roles, such as the Amazon EKS cluster policy and the Amazon EKS node group policy.
aws_iam_openid_connect_provider: Configures the OpenID Connect (OIDC) provider for the EKS cluster, which is required for certain Kubernetes features.
6. Security Groups:
The code also creates security groups for the EKS cluster and node group. These security groups define the inbound and outbound traffic rules for the resources, ensuring that the necessary communication is allowed between the cluster and the nodes.


# [  011-creation-ec2-rds  ]

Terraform code for creating an EC2 instance, applying a "Hello, World!" message on the web, creating a new security group related to the EC2 instance, creating a new RDS instance, and attaching the EC2 security group to the RDS security group.

EC2 Instance Creation:
The code creates an EC2 instance using the aws_instance resource.
It specifies the Amazon Machine Image (AMI) and instance type for the EC2 instance.
The instance is placed in a public subnet within the VPC.
The code attaches a security group to the EC2 instance, which will be created in the next step.
The user_data block contains a script that updates the package manager, installs Nginx, starts and enables the Nginx service, and creates an "index.html" file with the "Hello, World!" message.
Security Group Creation:
The code creates a new security group using the aws_security_group resource.
This security group is associated with the EC2 instance and defines the inbound and outbound traffic rules.
The inbound rules allow HTTP (port 80) and SSH (port 22) traffic to the EC2 instance.
The outbound rules allow all traffic from the EC2 instance.
RDS Instance Creation:
The code creates a new RDS instance using the aws_db_instance resource.
It specifies the engine type as "mysql" and sets the database name, username, and password.
The RDS instance is placed in a private subnet within the VPC.
The code attaches the security group created earlier to the RDS instance, ensuring that the EC2 instance can communicate with the database.
Additional RDS configuration parameters, such as instance class, storage, and backup settings, are also defined in the code.
Security Group Attachment:
The code attaches the security group created for the EC2 instance to the RDS instance using the aws_db_security_group resource.
This allows the EC2 instance to communicate with the RDS instance over the specified ports and protocols.
