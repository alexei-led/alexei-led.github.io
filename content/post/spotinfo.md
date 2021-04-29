+++
date = "2021-04-08T10:00:00+02:00"
draft = true
title = "Spotinfo"
tags = ["AWS", "EC2","Spot", "tool"]
categories = ["DevOps", "Cloud", "AWS"]
+++

## TL;DR

The `spotinfo` is a command-line tool you can use for exploring AWS Spot instances.

## Introduction

Using [Amazon EC2 Spot](https://aws.amazon.com/ec2/spot/) instances is an excellent way to reduce EC2 on-demand instance cost, up to 90%. Whenever you have a workload that can survive VM interruption or be suspended and resumed later on without impacting business use cases, choosing the Spot pricing model is a no-brainer choice.

The lower your interruption rate, the longer your Spot instances are likely to run.

Amazon provides an excellent web interface [AWS Spot Instance Advisor](https://aws.amazon.com/ec2/spot/instance-advisor/) to explore available Spot instances and determine spot instance pools with the least chance of interruption. You can also check the savings you get over on-demand rates. You can also check the savings you get over on-demand rates. And then, you are supposed to use these metrics for selecting appropriate Spot instances.

While the **AWS Spot Instance Advisor** is a valuable tool, it is not easy to use its data for scripting and automation, and some use cases require too many clicks.

## Spotinfo tool

That's why I created the `spotinfo` tool. It's an easy-to-use command-line tool (open source under Apache 2.0 License) that allows you to explore AWS Spot instances in a terminal and use the spot data it provides for scripting and automation.

Under the hood, the `spotinfo` is using two public data sources available from AWS:

1. **AWS Spot Instance Advisor** [data feed](https://spot-bid-advisor.s3.amazonaws.com/spot-advisor-data.json)
1. AWS Spot Pricing [data feed](http://spot-price.s3.amazonaws.com/spot.js)

### Features

The `spotinfo` allows you to access the same information you can see in the **AWS Spot Instance Advisor**, but from a command line and can be used for scripting and automation use cases. In addition, the tool provides some useful features that are not available for **AWS Spot Instance Advisor** web interface.

#### Advanced Filtering

The first feature is _advanced filtering+. You can filter spot instances by:

- vCPU - minimum number of CPU cores
- Memory GiB - minimum memory size
- Operating system - Linux or Windows
- Region - one or more AWS regions (or `all` AWS regions)
- Savings (compared to on-demand)
- Frequency of interruption
- Hourly rate (in `USD/hour`)

When filtering by instance type, [regular expressions](https://github.com/google/re2/wiki/Syntax) are supported. And this can help you create advanced queries.

##### Example: filter with Regex

List (as text) all available EC2 Spot instances powered by [Graviton2](https://aws.amazon.com/ec2/graviton/) processor, with a minimum of eight CPU cores, in the `us-west-2` (Oregon) region, sorting results by spot price.

```bash
spotinfo --type="^[[:alnum:]]{2}g\.\S*" --cpu=8 --region=us-west-2 --sort=price --output=text

## output
type=t4g.2xlarge, vCPU=8, memory=32GiB, saving=70%, interruption='<5%', price=0.08
type=c6g.2xlarge, vCPU=8, memory=16GiB, saving=50%, interruption='<5%', price=0.14
type=m6g.2xlarge, vCPU=8, memory=32GiB, saving=54%, interruption='<5%', price=0.14
type=r6g.2xlarge, vCPU=8, memory=64GiB, saving=63%, interruption='<5%', price=0.15
type=c6g.4xlarge, vCPU=16, memory=32GiB, saving=50%, interruption='<5%', price=0.27
type=m6g.4xlarge, vCPU=16, memory=64GiB, saving=54%, interruption='5-10%', price=0.28
type=r6g.4xlarge, vCPU=16, memory=128GiB, saving=63%, interruption='<5%', price=0.30
type=c6g.8xlarge, vCPU=32, memory=64GiB, saving=50%, interruption='<5%', price=0.54
type=m6g.8xlarge, vCPU=32, memory=128GiB, saving=54%, interruption='<5%', price=0.57
type=r6g.8xlarge, vCPU=32, memory=256GiB, saving=63%, interruption='<5%', price=0.59
type=c6g.12xlarge, vCPU=48, memory=96GiB, saving=50%, interruption='<5%', price=0.81
type=m6g.12xlarge, vCPU=48, memory=192GiB, saving=54%, interruption='<5%', price=0.85
type=r6g.12xlarge, vCPU=48, memory=384GiB, saving=63%, interruption='<5%', price=0.89
type=c6g.16xlarge, vCPU=64, memory=128GiB, saving=50%, interruption='<5%', price=1.08
type=c6g.metal, vCPU=64, memory=128GiB, saving=50%, interruption='<5%', price=1.08
type=m6g.metal, vCPU=64, memory=256GiB, saving=54%, interruption='<5%', price=1.14
type=m6g.16xlarge, vCPU=64, memory=256GiB, saving=54%, interruption='<5%', price=1.14
type=r6g.metal, vCPU=64, memory=512GiB, saving=63%, interruption='<5%', price=1.19
type=r6g.16xlarge, vCPU=64, memory=512GiB, saving=63%, interruption='<5%', price=1.19
```

#### Spot Price Visibility

With **AWS Spot Instance Advisor**, you can see a discount comparing to the on-demand EC2 instance rate. But to find out, what is the actual price, you are going to pay, you must visit a different [AWS Spot pricing](https://aws.amazon.com/ec2/spot/pricing/) web page and search it again for the specific instance type.

The `spotinfo` saves your time and can display the spot price alongside other information. You can also filter and sort by spot price if you like.

#### Flexible Output Formats

Working with data in a command line and accessing data from scripts and automation requires flexibility of output format. The `spotinfo` can return results in multiple formats: human-friendly formats, like `table` and plain `text`, and automation-friendly: `json`, `csv`, or just a saving number. Choose whatever format you need for any concrete use case.

#### Compare Spots across multiple Regions

One annoying thing about the **AWS Spot Instance Advisor**, is the inability to compare EC2 spot instances across multiple AWS regions. Only a single region view is available, or you need to open multiple browser tabs and constantly switch between them to compare spot instances across multiple AWS regions.

The `spotinfo` can help you to compare spot instances across multiple AWS regions. All you need to do is pass a `--region` command-line flag, and you can use this flag more than once.

Another option is to pass a special `all` value (with `--region=all` flag) to see spot instances across all available AWS regions.

##### Example: explore `t4g.small` Spot instance

Explore the `t4g.small` spot instance type availability and rate across **all** AWS regions, where this instance type is available.

```bash
spotinfo --type=t4g.small --output=table --region=all

# output
┌────────────────┬───────────────┬──────┬────────────┬────────────────────────┬───────────────────────────┬──────────┐
│ REGION         │ INSTANCE INFO │ VCPU │ MEMORY GIB │ SAVINGS OVER ON-DEMAND │ FREQUENCY OF INTERRUPTION │ USD/HOUR │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ us-west-2      │ t4g.small     │    2 │          2 │                    70% │ <5%                       │    0.005 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ ap-northeast-1 │ t4g.small     │    2 │          2 │                    70% │ <5%                       │   0.0065 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ eu-west-1      │ t4g.small     │    2 │          2 │                    70% │ <5%                       │   0.0055 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ ap-south-1     │ t4g.small     │    2 │          2 │                    70% │ <5%                       │   0.0034 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ us-east-2      │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │    0.005 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ ap-east-1      │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │    0.007 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ eu-central-1   │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │   0.0058 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ ap-southeast-2 │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │   0.0064 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ eu-north-1     │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │   0.0052 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ sa-east-1      │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │    0.008 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ ap-southeast-1 │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │   0.0064 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ us-east-1      │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │    0.005 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ ca-central-1   │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │   0.0055 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ us-west-1      │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │    0.006 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ ap-northeast-2 │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │   0.0062 │
├────────────────┼───────────────┼──────┼────────────┼────────────────────────┼───────────────────────────┼──────────┤
│ eu-west-2      │ t4g.small     │    2 │          2 │                    70% │ 5-10%                     │   0.0056 │
└────────────────┴───────────────┴──────┴────────────┴────────────────────────┴───────────────────────────┴──────────┘
```

#### Network Resilience

While the `spotinfo` uses public AWS data feeds, it also embeds the same data within the tool. So, if data feed is not available, for any reason (no connectivity, service not available or other), the `spotinfo` still will be able to return the same result.

### Summary

I hope the `spotinfo` could be a helpful tool for exploring AWS EC2 spot instances. And I'm looking forward to your comments and any questions you might have.

I invite you to contribute (issues, features, pull requests) to the [alexei-led/spotinfo](https://github.com/alexei-led/spotinfo) GitHub project.

_p.s._: if you like the `spotinfo` tool, please, consider giving the GitHub [project](https://github.com/alexei-led/spotinfo) a ⭐️.

---

*This is a **working draft** version. The final post version is published at [DoiT International Blog](https://blog.doit-intl.com/).*
