# Optimizely CMS Deployment Infrastructure

This project provides an end-to-end solution to deploy a highly available Optimizely Content Management System (CMS) application. The infrastructure is provisioned using Terraform and consists of various AWS services and Kubernetes components.

## Infrastructure Overview

The selected infrastructure includes:

- **Infrastructure as Code (IaC)**: Terraform for provisioning all cloud-based resources.
- **AWS EKS**: Managed Kubernetes cluster.
- **AWS ECR**: Docker container registry.
- **Helm**: Package manager for Kubernetes.
- **Nginx Ingress Controller**: For managing ingress traffic.
- **Cert-Manager**: For managing SSL/TLS certificates.
- **AWS RDS**: Managed SQL Server instance.
- **ASP.NET Core**: Application framework for the CMS.


## Prerequisites

Before start, ensure you have the following tools installed:

- **Terraform**: For provisioning infrastructure.
- **AWS CLI**: For interacting with AWS services.
- **kubectl**: Kubernetes CLI for managing the cluster.
- **Docker**: For building and pushing container images.
- **Helm**: For managing Kubernetes applications.

## Configuration

### Terraform
- **State Management**

For this exercise, we use a local state file for simplicity. However, for production environments, it is highly recommended to use a remote backend, such as an S3 bucket combined with a DynamoDB table, to ensure state locking and consistency. This setup helps prevent conflicts and data corruption by managing Terraform state files in a more reliable and secure manner.

- **EKS Cluster**

Be default the cluster will be created with Kubernetes version 1.29. This module is highly customizable, allowing specify parameters such as the number of nodes, instance types, and other configuration details to tailor the cluster to your specific needs.

The provision includes all necessary components to the EKS cluster, e.g: IAM roles, VPC, Security Group, Node group, etc.

- **ECR Repository**

Terraform provisions an Amazon Elastic Container Registry (ECR) repository to serve as a private Docker container registry. 

- **SQL server**

An AWS RDS instance is provisioned to host the SQL Server database. This managed database service ensures high availability, automated backups, and easy scaling for your application's data needs.

- **Cert-Manager**

Cert-Manager is installed to manage and automate the issuance and renewal of SSL/TLS certificates within the Kubernetes cluster. It supports various certificate authorities, including Let's Encrypt and self-signed certificates, to ensure secure communication for your applications.

- **External Secrets**

External Secrets integrates with external secret management systems, such as AWS Secrets Manager, to securely store and access sensitive data. It allows Kubernetes workloads to consume secrets from these external systems, providing an additional layer of security and management.

- **Nginx Ingress**

The Nginx Ingress Controller is deployed to manage incoming HTTP and HTTPS traffic for your Kubernetes applications. It provides load balancing, SSL termination, and routing capabilities, enabling you to expose your services securely and efficiently to the outside world.


### Getting Started

- **AWS CLI Configuration**

Ensure you have configured the AWS CLI with the appropriate credentials:

```sh
aws configure
```

- **Provision infrastructure**
Use terraform to provision the required infrastructure:
```sh
terraform plan
terraform apply
```

- **Retrieve Kubeconfig**

After provisioning the EKS cluster with Terraform, you need to update your kubeconfig to interact with the cluster. Run the following command to configure your local Kubernetes client:
```sh
export KUBECONFIG=~/.kube/.kubeconfig-AWS-LAB
aws eks update-kubeconfig --name logifuture-eks --region eu-west-1
```

- **Build and Push Docker Image**
Log in to ECR, build and push the Docker image:
```sh
# ECR login
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com

# Docker build & push
docker build -t <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/my-optimizely-cms:latest .
docker push <your-account-id>.dkr.ecr.eu-west-1.amazonaws.com/my-optimizely-cms:latest
```

- **Deploy application**
```sh
helm install -f values.yaml optimizely-cms . -n optimizely-cms --debug
```

# To-Do

- **Terraform**: Segregate cloud resource provisions and Kubernetes objects. Remove all kubernetes objects from Terraform and manage them separately with Helm and Flux.
- **Cert-Manager**: Fix ACME challenge validation.
- **CI Workflow**: Set up a CI pipeline to build and push Docker images to the registry.
- **GitOps**: Implement GitOps using tools like Flux or ArgoCD for continuous delivery.
- **Monitoring Stack**: Integrate monitoring solutions such as Prometheus, Grafana, Thanos, and Loki.
- **External Secrets**: Integrate External Secrets, Cert Manager, Helm Release, and Kustomization.
- **Authenticated ingress**: Add authentication to Nginx Ingress