---
layout: post
title: "Kubernetes and Secrets Management in Cloud: Part 2"
date: 2020-04-26T10:00:00+02:00
published: false
tags:
  - kubernetes
  - eks
  - gke
  - aws
  - gcp
  - secrets-manager
  - security
  - devsecops
categories:
  - DevOps
  - Security
  - Kubernetes
---

Secrets are essential for operation of many production systems. Unintended secrets exposure is one of the top risks that should be properly addressed. Developers should do their best to protect application secrets.

The problem becomes even harder, once company moves to a microservice architecture and multiple services require an access to different secrets in order to properly work. And this leads to a new challenges: how to distribute, manage, monitor and rotate application secrets, avoiding unintended exposure?

In the previous post [Part 1](https://engineering.doit.com/kubernetes-and-secrets-management-in-cloud-858533c20dca), I had showed a way of integrating AWS and Google Cloud secrets management services ([AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) and [Google Cloud Secret Manager](https://cloud.google.com/secret-manager)) with Kubernetes, using [doitintl/secrets-init](https://hub.docker.com/r/doitintl/secrets-init) _initContainer_ manually added into a target Pod.

In this post, I'm going to present a **Kubernetes-native** approach of integrating cloud secrets management services mentioned above.

## Automatic cloud secret injection

White it is possible to modify manually Kubernetes Deployment YAML files to use `secret-init` as a container init system, the better option would be if someone could do it for you and do it only for Kubernetes Pods that are referencing cloud secrets. Fortunately for us, Kubernetes allows to inspect and modify any Pod before container is created with a mechanism knows as [mutating admission webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/).

The [doitintl/kube-secrets-init](https://github.com/doitintl/kube-secrets-init) is an open source project from [DoiT International](https://www.doit-intl.com/) that implements a Kubernetes _mutating admission webhook_ for cloud secrets injection, supporting both AWS and Google Cloud managed secrets.

The `kube-secrets-init` monitors Kubernetes cluster for newly created or updated Pods adding an _initContainer_ with [doitintl/secrets-init](https://hub.docker.com/r/doitintl/secrets-init)) utility to the Pods that are referencing cloud secrets directly (through environment variables) or/and indirectly (through Kubernetes `Secret` and `ConfigMap`).

![Secret Init Webhook](/assets/images/k8s-secret-webhook.png)

### Integration with AWS Secrets Manager

User can put AWS secret [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) reference as an environment variable value. The `secrets-init` will resolve an environment value, using the specified ARN, to a referenced secret value.

```sh
# environment variable passed to `secrets-init`
DB_PASSWORD=arn:aws:secretsmanager:$AWS_REGION:$AWS_ACCOUNT_ID:secret:dbpassword-cdma3

# environment variable passed to the child process, resolved by `secrets-init`
DB_PASSWORD=very-secret-password
```

### Integration with AWS Systems Manager Parameter Store

It is possible to use AWS Systems Manager Parameter Store to store application parameters and secrets.

User can put AWS Parameter Store ARN reference as an environment variable. The `secrets-init` will resolve an environment value, using the specified ARN, to a referenced parameter store value.

```sh
# environment variable passed to `secrets-init`
API_KEY=arn:aws:ssm:$AWS_REGION:$AWS_ACCOUNT_ID:parameter/api/key

# environment variable passed to child process, resolved by `secrets-init`
API_KEY=key-123456789
```

### Integration with Google Secret Manager

User can put Google Secret name (prefixed with `gcp:secretmanager:`) as environment variable value. The `secrets-init` will resolve an environment value, using the specified name, to a referenced secret value. The secret name can include a secret version, to reference a specific version of the secret.

```sh
# environment variable passed to `secrets-init`
DB_PASSWORD=gcp:secretmanager:projects/$PROJECT_ID/secrets/db/password
# OR versioned secret (with version or 'latest')
DB_PASSWORD=gcp:secretmanager:projects/$PROJECT_ID/secrets/db/password/versions/2

# environment variable passed to child process, resolved by `secrets-init`
DB_PASSWORD=very-secret-password
```

### Requirement

#### AWS

In order to resolve AWS secrets from AWS Secrets Manager and Parameter Store, the `secrets-init` application should run under AWS IAM Role with one of the following IAM policies attached.

for AWS Secrets Manager:

```yaml
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "arn:aws:secretsmanager:us-west-2:123456789012:secret:aes128-1a2b3c"
    }
}
```

for AWS Systems Manager Parameter Store:

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:us-west-2:123456789012:parameter/prod-*"
        }
    ]
}
```

When running in EKS cluster, it's recommended to use [AWS IAM Roles for Service Account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).
It's also possible to assign an IAM Role to an EC2 instance, where container is running, but this option is considered to be less secure.

#### Google Cloud

In order to resolve Google secrets from Google Secret Manager, the `secrets-init` application should run under IAM role with sufficient permission to access desired secrets. For example, you can assign the following 2 predefined Google IAM roles to a Google Service Account: `Secret Manager Viewer` and `Secret Manager Secret Accessor` role.

In GKE cluster it is possible to assign IAM Role to Kubernetes Pod with [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity).
It's also possible to assign an IAM Role to a GCE instance, where container is running, but this option is considered to be less secure.

Uncomment `--provider=google` flag in the [deployment.yaml](https://github.com/doitintl/kube-secrets-init/blob/master/deployment/deployment.yaml) file.

## The webhook deployment

1. To deploy the `kube-secrets-init` webhook server, we need to create a webhook service and a deployment in our Kubernetes cluster. It’s pretty straightforward, except one thing, which is the server’s TLS configuration. If you’d care to examine the [deployment.yaml](https://github.com/doitintl/kube-secrets-init/blob/master/deployment/deployment.yaml) file, you’ll find that the certificate and corresponding private key files are read from command line arguments, and that the path to these files comes from a volume mount that points to a Kubernetes secret:

```yaml
[...]
      args:
      [...]
      - --tls-cert-file=/etc/webhook/certs/cert.pem
      - --tls-private-key-file=/etc/webhook/certs/key.pem
      volumeMounts:
      - name: webhook-certs
        mountPath: /etc/webhook/certs
        readOnly: true
[...]
   volumes:
   - name: webhook-certs
     secret:
       secretName: secrets-init-webhook-certs
```

The most important thing to remember is to set the corresponding CA certificate later in the webhook configuration, so the `apiserver` will know that it should be accepted. For now, we’ll reuse the script originally written by the Istio team to generate a certificate signing request. Then we’ll send the request to the Kubernetes API, fetch the certificate, and create the required secret from the result.

First, run [webhook-create-signed-cert.sh](https://github.com/doitintl/kube-secrets-init/blob/master/deployment/webhook-create-signed-cert.sh) script and check if the secret holding the certificate and key has been created:

```text
./deployment/webhook-create-signed-cert.sh

creating certs in tmpdir /var/folders/vl/gxsw2kf13jsf7s8xrqzcybb00000gp/T/tmp.xsatrckI71
Generating RSA private key, 2048 bit long modulus
.........................+++
....................+++
e is 65537 (0x10001)
certificatesigningrequest.certificates.k8s.io/secrets-init-webhook-svc.default created
NAME                         AGE   REQUESTOR              CONDITION
secrets-init-webhook-svc.default   1s    alexei@doit-intl.com   Pending
certificatesigningrequest.certificates.k8s.io/secrets-init-webhook-svc.default approved
secret/secrets-init-webhook-certs configured
```

Once the secret is created, we can create deployment and service. These are standard Kubernetes deployment and service resources. Up until this point we’ve produced nothing but an HTTP server that’s accepting requests through a service on port `443`:

```sh
kubectl create -f deployment/deployment.yaml

kubectl create -f deployment/service.yaml
```

### Configure mutating admission webhook

Now that our webhook server is running, it can accept requests from the `apiserver`. However, we should create some configuration resources in Kubernetes first. Let’s start with our validating webhook, then we’ll configure the mutating webhook later. If you take a look at the [webhook configuration](https://github.com/doitintl/kube-secrets-init/blob/master/deployment/mutatingwebhook.yaml), you’ll notice that it contains a placeholder for `CA_BUNDLE`:

```yaml
[...]
      service:
        name: secrets-init-webhook-svc
        namespace: default
        path: "/pods"
      caBundle: ${CA_BUNDLE}
[...]
```

There is a [small script](https://github.com/doitintl/kube-secrets-init/blob/master/deployment/webhook-patch-ca-bundle.sh) that substitutes the CA_BUNDLE placeholder in the configuration with this CA. Run this command before creating the validating webhook configuration:

```sh
cat ./deployment/mutatingwebhook.yaml | ./deployment/webhook-patch-ca-bundle.sh > ./deployment/mutatingwebhook-bundle.yaml
```

Create mutating webhook configuration:

```sh
kubectl create -f deployment/mutatingwebhook-bundle.yaml
```

### Configure RBAC for secrets-init-webhook

Create Kubernetes Service Account to be used with `secrets-init-webhook`:

```sh
kubectl create -f deployment/service-account.yaml
```

Define RBAC permission for webhook service account:

```sh
# create a cluster role
kubectl create -f deployment/clusterrole.yaml
# define a cluster role binding
kubectl create -f deployment/clusterrolebinding.yaml
```

## Summary

Hope, you find this post useful. I look forward to your comments and any questions you have.

You are also invited to contribute (Issues, Features, PRs) to the [doitintl/kube-secrets-init](https://github.com/doitintl/kube-secrets-init) GitHub Project.

---

*This is a **working draft** version. The final post version is published at [DoiT Blog](https://engineering.doit.com/) .*
