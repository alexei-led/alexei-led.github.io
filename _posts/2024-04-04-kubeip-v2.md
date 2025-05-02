---
layout: post
title: "KubeIP v2: Assigning Static Public IPs to Kubernetes Nodes Across Cloud Providers"
date: 2024-04-04T10:00:00+02:00
published: false
tags:
  - AWS
  - Google Cloud
  - Static IP
  - Kubernetes
  - KubeIP
  - Public IP
  - NAT Gateway
  - IPv4
  - IPv6
categories:
  - DevOps
  - Cloud
  - AWS
  - GCP
  - Kubernetes
---


## TL;DR

Kubernetes nodes can benefit from having dedicated static public IP addresses in certain scenarios.

[KubeIP](https://github.com/doitintl/kubeip), an open-source utility, fulfills this need by assigning static public IPs to Kubernetes nodes. The latest version, KubeIP v2, extends support from Google Cloud's GKE to Amazon's EKS, with a design that's ready to accommodate other cloud providers. It operates as a DaemonSet, offering improved reliability, configuration flexability and user-friendliness over the previous Kubernetes controller method. KubeIP v2 supports assigning both IPv4 and IPv6 addresses. 

This post will delve into specific use cases for KubeIP, compare it with cloud NAT gateways, and explore the KubeIP architecture and configuration. 

## Use Cases

KubeIP is useful in a variety of scenarios where Kubernetes nodes need static public IPs. Here are some common use cases:

### Gaming Applications

In gaming scenarios, a console may need to establish a direct connection to a cloud VM to minimize network hops and latency. Assigning a dedicated public IP to the node hosting the gaming server allows the console to connect directly. This can improve the gaming experience by reducing latency and packet loss.

### Whitelisting Agent IPs

If you have multiple agents or services running on Kubernetes that require direct connections to an external server, and that server needs to whitelist the IP addresses of the agents, using KubeIP to assign stable public IPs to the nodes makes this easier to manage compared to allowing broader CIDR ranges. This is particularly useful in scenarios where the external server has strict IP-based access controls.

### Avoiding SNAT for Select Pods

By default, pods are assigned private IPs from the VPC CIDR range. When they communicate with external IPv4 addresses, the Amazon VPC CNI plugin translates the pod's IP to the primary private IP of the node's network interface using SNAT (source network address translation).

In some cases, you may want to avoid SNAT for certain pods so that external services see the actual pod IPs. Assigning public IPs to nodes with KubeIP and setting `hostNetwork: true` on the pod spec achieves this. The pod can then communicate directly with external services using the node's public IP.

### Direct Inbound Connections and Custom Networking Scenarios

Assigning public IPs to nodes with KubeIP enables a variety of networking scenarios. For instance, you can forward traffic directly to pods running on those nodes, which is useful when you need to expose services on the node to the internet without using a traditional load balancer. An example of this would be running a web server on a pod and forwarding traffic to it using the node's public IP.

In addition, KubeIP can be used to implement custom networking scenarios that require public IPs on nodes. For example, you could create a custom load balancer that forwards traffic to specific nodes based on the public IP. This flexibility makes KubeIP a powerful tool for testing or deploying custom networking solutions in Kubernetes.

### IPv6 Support

KubeIP extends its functionality beyond IPv4 by also supporting the assignment of static public IPv6 addresses to nodes. This feature is increasingly important as the internet continues its transition towards IPv6 due to the exhaustion of IPv4 addresses.

With KubeIP's IPv6 support, you can assign static public IPv6 addresses to your Kubernetes nodes, enabling them to communicate directly with external services over IPv6. This is particularly beneficial for applications that require IPv6 connectivity. For instance, if you're developing or deploying an application that needs to support IPv6, you can use KubeIP to provide IPv6 connectivity to the pods running your application.

Moreover, IPv6 offers a larger address space, simplified header format, improved support for extensions and options, better multicast routing, and other enhancements over IPv4.

## Comparison with Cloud NAT Gateways

NAT gateways are a managed cloud service that provide outbound internet access for resources in private subnets by translating their private IPs to a public IP. They are designed to allow resources in a private network to initiate outbound connections to the internet, while maintaining the privacy and security of those resources.

However, NAT gateways do not support inbound connections, nor do they assign public IPs directly to resources. This means that while they are excellent for providing secure outbound access, they are not designed to handle scenarios where inbound connections are required, or where resources need to have their own public IPs.

KubeIP, on the other hand, assigns static public IPs directly to Kubernetes nodes. This allows inbound connections to be made directly to pods running on those nodes, by forwarding the traffic from the node to the pod. This can be particularly useful for applications that need to be accessible from the internet, or for custom networking scenarios.

In addition, when `hostNetwork` is enabled, pods can initiate outbound connections using the host's IP address directly. This can improve network performance and simplify network troubleshooting, although it should be used carefully due to potential security considerations.

In summary, while NAT gateways are a great solution for secure outbound access, KubeIP provides additional flexibility and control over both inbound and outbound connectivity for specific pods and nodes.

## Cost Comparison: KubeIP vs Cloud NAT Gateways

When considering the cost of using KubeIP versus cloud NAT gateways, there are several factors to consider.

### Cloud NAT Gateways Costs

Cloud NAT gateways are a managed service, which means they come with a cost. The cost typically depends on the amount of data processed and the time the NAT gateway is provisioned and available. For example, as of the time of writing, AWS charges $0.045 per hour for a NAT gateway plus data processing charges. You also incur standard AWS data transfer charges for all data transferred via the NAT gateway. The pricing model for Google Cloud NAT is similar.

### KubeIP Costs

KubeIP, on the other hand, is an open-source tool, so there are no direct costs associated with its use. However, there are several indirect costs to consider:

1. **Static Public IP Addresses**: You will need to pay for the static public IP addresses that you assign to your nodes. The cost of these IP addresses varies by cloud provider. For instance, AWS charges $0.005 per hour for an Elastic IP address whether it's in use or not. Google Cloud charges the same amount for a static IP address.

2. **Data Transfer**: Standard data transfer charges apply for data transferred via the assigned static public IP addresses. These costs will depend on your cloud provider's data transfer pricing.

3. **Additional Workload on Cluster**: While KubeIP operates as a DaemonSet and does not consume much resources in terms of CPU and memory, it is still an additional workload running on your Kubernetes cluster. This could potentially impact the performance of other workloads, especially on clusters with limited resources. However, in most cases, the impact should be minimal.

4. **Maintenance and Support**: As an open-source tool, KubeIP does not come with dedicated support. Any maintenance, troubleshooting, or updates will need to be handled by your team. While this doesn't have a direct cost, it does require time and effort, which can translate into a cost for your organization.

In summary, while KubeIP does not have a direct cost, there are several indirect costs that should be considered. However, for many use cases, the flexibility and control offered by KubeIP can outweigh these costs.

### Cost Considerations

When evaluating the cost-effectiveness of KubeIP, it's important to consider both the direct and indirect costs associated with its use. These include the cost of static public IP addresses, data transfer charges, the potential impact of running an additional workload on your Kubernetes cluster, and the time and effort required for maintenance and support.

While KubeIP does not have a direct cost, these indirect costs can add up, especially for larger clusters. However, the flexibility and control offered by KubeIP can provide significant value, particularly for use cases that require direct inbound connections or custom networking scenarios.

Cloud NAT gateways, on the other hand, provide a managed service that can simplify outbound connectivity for resources in private subnets. While there is a cost associated with this service, it includes benefits such as ease of use, scalability, and reliability.

In conclusion, the choice between KubeIP and a cloud NAT gateway will depend on your specific use case, the size and requirements of your Kubernetes cluster, and your budget. It's recommended to calculate the costs based on your expected data transfer, number of nodes/IP addresses, and maintenance needs to make an informed decision.

## IPv6 Support in KubeIP v2

As of version 2, KubeIP supports assigning IPv6 addresses to nodes in addition to IPv4. This aligns with the growing adoption of IPv6 in Kubernetes clusters and enables some unique use cases. For example, you could use it to provide IPv6 connectivity to pods running on specific nodes. This is particularly useful in scenarios where you need to test or deploy IPv6-enabled applications.

## How KubeIP Works

KubeIP runs as a DaemonSet on your desired nodes. On each node, it:

1. Discovers information about the node and cloud provider using the Kubernetes Downward API.
2. Acquires a cluster-wide lock to ensure that only one node is assigning an IP at a time, preventing race conditions and IP conflicts.
3. Selects an available static IP from the configured pool using filters and selectors.
4. Assigns the IP to the node's primary network interface using the cloud provider's API.
5. If the assignment fails due to an error, such as a network interruption or API error, KubeIP will retry the assignment up to a configured limit.
6. When a node is deleted, KubeIP releases the assigned IP back to the pool, making it available for other nodes.

KubeIP supports both IPv4 and IPv6 addresses, and it can be configured to use different pools for each. It also supports custom IP pools for different nodes or node groups, providing flexibility in IP management.

## KubeIP Architecture

KubeIP v2 is architected as a standard Kubernetes DaemonSet, which means it runs on each node in the cluster. This design enhances reliability and ease of use compared to the previous controller-based design. It also simplifies the deployment process and ensures that each node gets a public IP. Moreover, by leveraging standard Kubernetes features like node selectors or node affinity, you can control on which nodes KubeIP is deployed. This allows for fine-grained control over IP assignment, enabling you to assign public IPs to specific nodes based on your requirements.

The extensible design of KubeIP v2 allows for easy integration with other cloud providers beyond GKE and EKS, making it a versatile tool for managing public IPs in multi-cloud environments.

## Configuring KubeIP

KubeIP requires a Kubernetes service account with permissions to get nodes and manage leases.

On the cloud side, it needs an IAM role or service account with permissions to assign/unassign and list public IPs and get node info. Here's an example AWS IAM policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateAddress",
        "ec2:DisassociateAddress", 
        "ec2:DescribeInstances",
        "ec2:DescribeAddresses"
      ],
      "Resource": "*"
    }
  ]
}
```

And a Google Cloud IAM role:

```yaml
title: "KubeIP Role"
description: "KubeIP required permissions"
stage: "GA"
includedPermissions:
- compute.instances.addAccessConfig
- compute.instances.deleteAccessConfig
- compute.instances.get
- compute.addresses.get
- compute.addresses.list
- compute.addresses.use
- compute.zoneOperations.get
- compute.subnetworks.useExternalIp
- compute.projects.get
```

To select which IPs to use, specify filters using the same syntax as the cloud CLI/API for listing IPs. For example:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kubeip
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: kubeip
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: kubeip
    spec:
      serviceAccountName: kubeip-service-account
      terminationGracePeriodSeconds: 30
      priorityClassName: system-node-critical
      nodeSelector:
        nodegroup: public
        kubeip: "use"
      tolerations:
        - operator: "Exists"
          effect: "NoSchedule"
        - operator: "Exists"
          effect: "NoExecute"
      containers:
      - name: kubeip
        image: doitintl/kubeip-agent
        imagePullPolicy: Always
        resources:
          requests:
            cpu: "10m"
            memory: "32Mi"
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: LEASE_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: FILTER
          value: "Name=tag:kubeip,Values=reserved;Name=tag:environment,Values=prod"
        - name: LOG_LEVEL
          value: "debug"
        - name: LOG_JSON
          value: "true"
```

This tells KubeIP on AWS to only consider IPs with tags `kubeip=reserved` and `environment=prod`. Multiple filters are ANDed together.

## Trying It Out

The [examples](https://github.com/doitintl/kubeip/tree/main/examples) directory contains Terraform configurations to spin up GKE and EKS clusters with KubeIP deployed. 

To run on EKS:

```shell
cd examples/aws

terraform init

terraform apply
```

And on GKE:

```shell
cd examples/gcp

terraform init 

# without IPv6 support
terraform apply -var="project_id=<your-project-id>"

# with IPv6 support
terraform apply -var="project_id=<your-project-id>" -var="ipv6_support=true"
```

This will provision a cluster with public and private node pools, reserve some static IPs, and deploy the KubeIP DaemonSet configured to use the reserved IPs.

## Conclusion

KubeIP v2 is a powerful tool for assigning static public IPs to Kubernetes nodes across cloud providers. It enables a wide range of use cases, from gaming applications to custom networking scenarios, and supports both IPv4 and IPv6 addresses. The extensible design and simplified DaemonSet model make it easy to deploy and manage in your environment.

## Wrapping Up

KubeIP v2 is a powerful tool that brings robustness and flexibility to managing static public IPs in Kubernetes clusters, regardless of the cloud provider. Its unique capability to assign public IPs directly to nodes paves the way for a multitude of possibilities. Whether you need to enable direct inbound connections or facilitate custom networking scenarios, KubeIP v2 has you covered.

One of the key strengths of KubeIP v2 is its readiness for the future of internet connectivity. It supports both IPv4 and IPv6 addresses, ensuring it stays relevant as the internet continues to evolve. Furthermore, its deployment as a DaemonSet not only simplifies the setup process but also enhances reliability.

KubeIP v2 also shines in its flexibility. With the ability to deploy KubeIP on specific nodes using standard Kubernetes features like node selectors or node affinity, you gain granular control over IP assignment.

While using KubeIP does come with costs, such as those for static public IP addresses and potential data transfer charges, these are often balanced out by the benefits. The direct connectivity and the flexibility to handle unique networking requirements that KubeIP offers can often outweigh these costs.

In conclusion, KubeIP v2 is more than just a tool for assigning static public IPs. It's a comprehensive solution that can enhance your Kubernetes networking, simplify your IP management, and unlock new possibilities for your applications.

## Get Involved

As an open-source [project](https://github.com/doitintl/kubeip), we welcome contributions! Submit pull requests, open issues, help with documentation, or spread the word.

With the expanded cloud support and simplified DaemonSet model in v2, we're excited to see more use cases enabled by KubeIP. Give it a try in your environment and let us know how it goes!

---

*This is a **working draft** version. The final post version is published at [DoiT International Blog](https://engineering.doit.com/).*
