# Supabase on AWS EKS – Production Deployment

## 1. Architecture Overview

- **EKS Cluster**: Hosts all Supabase components (Postgres, Kong, PostgREST, Realtime, Auth, Studio, Storage).
- **AWS Secrets Manager**: Stores all sensitive credentials, synced to Kubernetes via the Secrets Store CSI Driver.
- **Karpenter**: Provides dynamic node autoscaling for cost and performance efficiency.
- **ALB Ingress Controller**: Exposes services securely via AWS Application Load Balancer.
- **Cert-Manager**: Issues TLS certificates for Ingress endpoints.
- **S3**: Used for storage and Postgres backups.

## 2. Technology Choices Justification
- **EKS**: Managed Kubernetes for scalability and reliability.
- **Supabase**: Open-source backend suite.
- **Secrets Store CSI Driver**: Secure, native secrets sync from AWS Secrets Manager.
- **Karpenter**: Modern, flexible autoscaler for Kubernetes.
- **ALB Ingress**: Native AWS load balancing and SSL termination.
- **Cert-Manager**: Automated certificate management.
- **S3**: Durable, cost-effective object storage.

## 3. Prerequisites & Setup Instructions
- AWS CLI, kubectl, helm, eksctl installed
- AWS account with sufficient permissions
- EKS cluster created (see `aws-infra/` Terraform)
- IAM roles for service accounts (IRSA) set up for CSI, Karpenter, ALB, etc.

## 4. Deployment Instructions
1. **Install CSI Driver & AWS Provider**
    - See `k8s/secretproviderclass/` for manifests and Helm commands.
2. **Install cert-manager**
    ```sh
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    kubectl create namespace cert-manager
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.14.4
    ```
3. **Install ALB Ingress Controller**
    - See `k8s/aws-ingress/notes.txt` for commands.
4. **Create ACM Certificate for Ingress**
    - In AWS ACM, request a public certificate for `supabase.zicodev.com` (or your domain).
    - Validate the certificate via DNS or email as prompted by AWS.
    - Note the ACM certificate ARN (e.g., `arn:aws:acm:us-east-1:...`).
    - In your Kong Ingress and/or other Ingress manifests, set the annotation:
      `alb.ingress.kubernetes.io/certificate-arn: <your-acm-certificate-arn>`
    - This enables HTTPS for your Ingress using the ACM certificate.
5. **Configure DNS (A Record) for Domain**
    - In your DNS provider (e.g., Route53, GoDaddy), create an A record for `supabase.zicodev.com`.
    - Point this A record to the ALB DNS name provisioned by the Ingress (find with `kubectl get ingress -n supabase`).
    - This will route traffic from your custom domain to the Supabase dashboard securely.
4. **Install Karpenter**
    - See `k8s/autoscale/` for Helm and IRSA setup.
5. **Deploy Supabase**
    ```sh
    helm repo add supabase https://supabase-community.github.io/supabase-kubernetes
    helm repo update
    helm upgrade --install supabase supabase/supabase -n supabase -f k8s/supabase/values.yaml
    ```
6. **Apply HPAs**
    ```sh
    kubectl apply -f k8s/autoscale/
    ```

## 5. Verification
- **Endpoints**: Check ALB DNS in AWS console or via `kubectl get ingress -A`
- **Custom Domain**: Visit `https://supabase.zicodev.com` to access the Supabase dashboard via your custom domain and ACM certificate.
- **Logs**: `kubectl logs -n supabase <pod>`
- **Metrics**: `kubectl top pods -n supabase`
- **Secret Rotation**: Update secret in AWS Secrets Manager, verify sync in Kubernetes

## 6. Tear-down Instructions
- Delete Helm releases:
  ```sh
  helm uninstall supabase -n supabase
  helm uninstall cert-manager -n cert-manager
  helm uninstall karpenter -n karpenter
  # ...other releases
  ```
- Delete EKS cluster and all resources (if using Terraform, run `terraform destroy` in `aws-infra/`)
- Remove S3 buckets and secrets in AWS manually if needed

- **Secrets Management**: All credentials managed in AWS Secrets Manager, synced via IRSA and CSI driver.
    - Secret rotation automation in AWS Secrets Manager is currently disabled for this deployment, but can be enabled and scheduled as needed. When enabled, AWS will automatically rotate secrets on your defined schedule, and the CSI driver will sync updated values into Kubernetes.
- **Least Privilege**: IAM roles scoped to only required actions for each component.
- **Network Security**: Use of private subnets, security groups, and network policies.
- **Scalability**: Karpenter and HPA ensure both node and pod autoscaling.

## 8. Challenges & Learnings
- The AWS Secrets Store CSI EKS addon does not provide all the functionality needed for managing secrets. The syncSecret option is not available via the EKS managed addon, so the csi-secrets-store Helm chart had to be used to enable SyncSecrets and secret syncing into Kubernetes.
- With the EKS addon, even after creating a SecretProviderClass and referencing a secret in a pod, the driver did not automatically create the Kubernetes secret from AWS Secrets Manager. This required switching to the Helm-based installation for full secret sync support.
- CSI driver and IRSA setup can be tricky; namespace and permissions must match exactly.
- Helm charts expect secrets to have specific labels/annotations for adoption.
- Karpenter requires correct cluster endpoint and IAM setup.

## 9. Future Improvements
- Spend more time ensuring all application secrets are read directly from AWS Secrets Manager by creating and validating the necessary SecretProviderClass resources for each workload. This guarantees that no sensitive data is hardcoded or stored insecurely in Kubernetes.
- Integrate ArgoCD to automate the deployment of new images and configuration changes, enabling GitOps workflows for continuous delivery and improved auditability.
- Enhance observability by installing the ELK stack (Elasticsearch, Logstash, Kibana) to collect and analyze logs from all Kubernetes workloads, or use Prometheus and Grafana for robust metrics-based monitoring.
- With Prometheus in place, leverage KEDA (Kubernetes Event-Driven Autoscaling) to create advanced scaling configurations based on custom or external metrics, not just CPU/memory.
- Add CI/CD pipeline for automated deployments
- Enable multi-AZ Postgres for HA
- Use ExternalDNS for automated DNS management
- Add WAF and advanced security policies


