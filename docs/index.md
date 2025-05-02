---
layout: home
---
# Alexei's Blog

This is a collection of articles I've written over the years, organized by date.

## 2025
- **[Kubernetes 1.33: Resizing Pods Without the Drama (Finally!) 🎉](/pod_resize_in_place.md)** (2025-04-26)
  *Tags: kubernetes, vpa, devops, autoscaling*
  Remember that feeling? You meticulously configured your Kubernetes pods, set the CPU and memory just right (or so you thought), only to have your application start gasping for air or hogging resources like it's Black Friday for RAM.

## 2024
- **[KubeIP v2: Assigning Static Public IPs to Kubernetes Nodes Across Cloud Providers](/kubeip_v2.md)** (2024-04-04)
  *Tags: AWS, Google Cloud, Static IP, Kubernetes, KubeIP, Public IP, NAT Gateway, IPv4, IPv6*
  Kubernetes nodes can benefit from having dedicated static public IP addresses in certain scenarios.

## 2021
- **[Spotinfo](/spotinfo.md)** (2021-04-08)
  *Tags: AWS, EC2, Spot, tool*
  The `spotinfo` is a command-line tool you can use for exploring AWS Spot instances.

## 2020
- **[Kubernetes and Secrets Management in Cloud: Part 2](/kube_secrets-init.md)** (2020-04-26)
  *Tags: Kubernetes, EKS, GKE, AWS, Google Cloud, Secrets Manager*
  Secrets are essential for operation of many production systems. Unintended secrets exposure is one of the top risks that should be properly addressed.

- **[Securely access AWS from GKE](/gke_aws_access.md)** (2020-02-12)
  *Tags: Kubernetes, GKE, AWS, GCP, IAM, security*
  It is not a rare case when an application running on Google Kubernetes Engine (GKE) needs to access Amazon Web Services (AWS) APIs.

- **[Building Multi-Platform Docker Images for Intel and ARM with AWS CodeBuild](/docker_multi_arch_aws.md)** (2020-09-30)
  *Tags: Docker, AWS, CodeBuild, DevOps, CI/CD, ARM, Multi-Arch*
  The Docker BuildKit buildx CLI plugin simplifies building Docker images for different OS/CPU platforms.

## 2019
- **[Kubernetes and Secrets Management in Cloud](/secrets-init.md)** (2019-12-23)
  *Tags: Kubernetes, EKS, GKE, AWS, GCP, Secrets Manager*
  Secrets are essential for operation of many production systems. Unintended secrets exposure is one of the top risks that should be properly addressed.

- **[EKS GPU Cluster from Zero to Hero](/eks_gpu_spot.md)** (2019-07-20)
  *Tags: Kubernetes, EKS, GPU, Spot, AWS, Machine Learning*
  If you ever tried to run a GPU workload on Kubernetes cluster, you know that this task requires non-trivial configuration and comes with high cost tag (GPU instances are quite expensive).

- **[Get a Shell to a Kubernetes Node](/k8s_node_shell.md)** (2019-07-27)
  *Tags: Kubernetes, DevOps, root, AWS, SSH*
  Throughout the lifecycle of your Kubernetes cluster, you may need to access a cluster worker node.

- **[Kubernetes Continuous Integration](/kubernetes_continuous_integration.md)** (2019-03-08)
  *Tags: Kubernetes, CI/CD, Continuous Integration, Helm*
  Complex Kubernetes application consists from multiple Kubernetes resources, defined in YAML files.

## 2017
- **[Chaos Testing for Docker Containers](/pumba_containercamp.md)** (2017-10-04)
  *Tags: docker, chaos monkey, chaos testing, chaos, testing, devops, chaos engineering, netem, network emulation*
  What follows is the text of my presentation, *Chaos Testing for Docker Containers* that I gave at ContainerCamp in London this year.

- **[Debugging remote Node.js application running in a Docker container](/debug_node_in_docker.md)** (2017-06-03)
  *Tags: docker, tutorial, devops, hacks, node, node.js, debug, Dockerfile*
  Suppose you want to debug a Node.js application already running on a remote machine inside Docker container.

- **[Create lean Node.js image with Docker multi-stage build](/node_docker_multistage.md)** (2017-04-25)
  *Tags: docker, tutorial, devops, hacks, node, node.js, multistage, Dockerfile*
  Starting from Docker 17.05+, you can create a single `Dockerfile` that can build multiple helper images with compilers, tools, and tests and use files from above images to produce the **final** Docker image.

- **[Crafting perfect Java Docker build flow](/perfect_docker_java.md)** (2017-03-07)
  *Tags: docker, tutorial, devops, hacks, java, maven*
  What is the bare minimum you need to **build**, **test** and **run** my Java application in Docker container?

## 2016
- **[Everyday hacks for Docker](/everyday_hacks.md)** (2017-01-02)
  *Tags: docker, tutorial, devops, hacks*
  In this post, I've decided to share with you some useful commands and tools, I'm frequently using, working with amazing Docker technology.

- **[Deploy Docker Compose (v3) to Swarm (mode) Cluster](/composev3_swarm.md)** (2016-12-18)
  *Tags: docker, swarm, docker-compose, compose, devops, cluster*
  Docker 1.13 simplifies deployment of composed application to a swarm (mode) cluster.

- **[Do not ignore .dockerignore](/donot_ignore_dockerignore.md)** (2016-11-26)
  *Tags: Docker, build, dockerignore, devops*
  Consider to define and use `.dockerignore` file for every Docker image you are building. It can help you to reduce Docker image size, speedup `docker build` and avoid unintended secret exposure.

- **[Docker Swarm cluster with docker-in-docker on MacOS](/swarm_dind.md)** (2016-10-06)
  *Tags: Docker, Swarm, MasOS, 1.12*
  Docker-in-Docker [dind] can help you to run Docker Swarm cluster on your Macbook only with Docker for Mac (v1.12+). No `virtualbox`, `docker-machine`, `vagrant` or other app is required.

- **[Network emulation for Docker containers](/pumba_docker_netem.md)** (2016-08-01)
  *Tags: Docker, testing, chaos testing, netem, network*
  Pumba `netem delay` and `netem loss` commands can emulate network *delay* and *packet loss* between Docker containers, even on single host. Give it a try!

- **[Pumba - Chaos Testing for Docker](/pumba_docker_chaos_testing.md)** (2016-04-16)
  *Tags: Docker, testing, chaos testing, resilience*
  The best defense against unexpected failures is to build resilient services. Testing for resiliency enables the teams to learn where their apps fail before the customer does.

- **[Testing Strategies for Docker Containers](/docker_testing.md)** (2016-03-07)
  *Tags: Docker, testing, integration test, Dockerfile*
  Congratulations! You know how to build a Docker image and are able to compose multiple containers into a meaningful application.

- **[Docker Pattern: The Build Container](/docker_builder_pattern.md)** (2016-01-14)
  *Tags: Docker, pattern, Dockerfile*
  Let's say that you're developing a microservice in a compiled language or an interpreted language that requires some additional "build" steps to package and lint your application code.

## 2015
- **[Docker Pattern: Deploy and update dockerized application on cluster](/docker_cd_cluster.md)** (2015-12-30)
  *Tags: Docker, CoreOS, fleet*
  Docker is great technology that simplifies development and deployment of distributed applications.
