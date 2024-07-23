resource "null_resource" "kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --kubeconfig /mnt/c/Users/Lucas/.kube/.kubeconfig-AWS-LOCALTEST"
  }
}

resource "kubernetes_namespace" "optimizely_cms" {
  metadata {
    name = "optimizely-cms"
  }

  depends_on = [ module.eks ]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
  depends_on = [module.eks, null_resource.kubeconfig]
}

# Cert-Manager Helm Release
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.15.1"

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "extraArgs[0]"
    value = "--issuer-ambient-credentials=false"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager.arn
  }

  set {
    name  = "extraArgs"
    value = "{--enable-certificate-owner-ref=true,--dns01-recursive-nameservers=https://1.1.1.1/dns-query}"
  }
  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  # Setting podDnsConfig
  set {
    name  = "podDnsConfig.nameservers[0]"
    value = "1.1.1.1"
  }

  set {
    name  = "podDnsConfig.nameservers[1]"
    value = "8.8.8.8"
  }

  # Setting podDnsPolicy
  set {
    name  = "podDnsPolicy"
    value = "ClusterFirstWithHostNet"
  }
  
  depends_on = [module.eks, null_resource.kubeconfig]
}

resource "aws_iam_role" "cert_manager" {
  name = "cert-manager-eks-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::211125468806:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/F5322063261F1072EA36CD2CF51CDAAD"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals": {
            "oidc.eks.eu-west-1.amazonaws.com/id/F5322063261F1072EA36CD2CF51CDAAD:sub": "system:serviceaccount:cert-manager:cert-manager"
          }
        }
      },
      {
        Sid: "",
        Effect: "Allow",
        Principal: {
            "AWS": "arn:aws:iam::211125468806:root"
        },
        Action: "sts:AssumeRole",
        Condition: {
            "ArnLike": {
                "aws:PrincipalArn": "arn:aws:iam::211125468806:role/cert-manager-eks-irsa-role"
            }
        }
        }
    ]
  })
}

resource "aws_iam_role_policy" "cert_manager_policy" {
  name = "cert-manager-policy"
  role = aws_iam_role.cert_manager.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = "*"
      },
      {
        Action: "route53:GetChange",
        Effect: "Allow",
        Resource: "arn:aws:route53:::change/*",
        Sid: "Route53"
      },
      {
        Action: [
            "route53:ListResourceRecordSets",
            "route53:ChangeResourceRecordSets"
        ],
        Effect: "Allow",
        Resource: [
            "arn:aws:route53:::hostedzone/Z0980613TA7C1OGZICD3"
        ],
      },
      {
        Action: "route53:ListHostedZonesByName",
        Effect: "Allow",
        Resource: "*",
        Sid: "ListHostedZones"
      },
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "*"
      }
    ]
  })
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
  depends_on = [module.eks, null_resource.kubeconfig]
}

# External Secrets Helm Release
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://external-secrets.github.io/kubernetes-external-secrets/"
  chart      = "kubernetes-external-secrets"
  version    = "8.1.0"  

  namespace = kubernetes_namespace.external_secrets.metadata[0].name

  depends_on = [module.eks, null_resource.kubeconfig]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
  depends_on = [module.eks, null_resource.kubeconfig]
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.19" 
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  depends_on = [module.eks, null_resource.kubeconfig]
}