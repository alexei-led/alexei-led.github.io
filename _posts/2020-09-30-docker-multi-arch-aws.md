---
layout: post
title: "Building Multi-Platform Docker Images for Intel and ARM with AWS CodeBuild"
date: 2020-09-30T10:00:00+02:00
published: false
tags:
  - docker
  - aws
  - codebuild
  - devops
  - ci/cd
  - arm
  - multi-arch
  - buildx
categories:
  - DevOps
  - CI/CD
  - Docker
---

The Docker BuildKit [buildx CLI plugin](https://github.com/docker/buildx) simplifies building Docker images for different OS/CPU platforms (e.g. `linux/amd64`, `linux/arm64`, `linux/arm`, `windows/amd64`)

So why is it a big deal now? Who needs Docker images for Arm platform anyway. Raspberry Pi geeks?

A good reason for this is just a one word Graviton2...
