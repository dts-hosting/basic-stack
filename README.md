# Basic stack

Creates a minimal stack of resources in AWS for development / testing.

- VPC and related resources (subnets, route tables etc.)
  - default ("10.0.0.0/16")
  - single public subnet only
- Security groups
  - SSH is allowed by default ("0.0.0.0/0")
- EC2 instances
  - SSH keys are created and available as outputs

## Requirements

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://www.terraform.io/)

Before running Terraform ensure that you have the AWS CLI
configured and working. An easy and typical way to do it is
using environment variables:

```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
```

But there are [many ways](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
to do it.

## Setup

Run the bootstrap script to create an S3 bucket for storing
Terraform state.

```bash
# region default: us-west-2
./bootstrap.sh $BUCKET [$REGION]

# or, if you're using AWS profiles to handle multiple accounts
AWS_PROFILE=$profile ./bootstrap.sh $BUCKET [$REGION]
```

*Note: the same bucket can be used to create multiple stacks by
specifying a different Terraform state key in the backend config.*

**Warning: this project is for basic (non-production) stacks so
there is no DynamoDB table configuration for state locking.**

## Config (Terraform backend)

In the `deploy` folder create `basic-stack1.conf` with contents:

```hcl
bucket  = "$bucket_name" # an AWS s3 bucket name
key     = "$bucket_key"  # Terraform state file name
region  = "$region"      # aws region of the resources
encrypt = true           # apply default encryption
```

Save this file as it will be needed when running Terraform.

## Config (basic stack resources)

In the `deploy` folder create `basic-stack1.yml` with contents:

```yml
# [unique] name of project
name: Basic stack 1
# [unique] name and / or prefix for created resources
resource_prefix: basic-stack1
# list of ec2 instances to create
instances:
  - ami_distro: "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ami_owner: "099720109477"
    name: runner
    type: t4g.nano
    root_volume_size: 50
    user_data: >
      #!/bin/bash
      sudo apt-get update && sudo apt-get -y install curl
```

## Creating resources

```bash
cd deploy/

terraform init -backend-config=basic-stack1.conf
terraform plan -var config_file=basic-stack1.yml
terraform apply -var config_file=basic-stack1.yml

# or, if you're using AWS profiles to handle multiple accounts
AWS_PROFILE=$profile terraform init -backend-config=basic-stack1.conf
AWS_PROFILE=$profile terraform plan -var config_file=basic-stack1.yml
AWS_PROFILE=$profile terraform apply -var config_file=basic-stack1.yml
```

*Note: the configuration files are not version controlled with this
repository to make it a more public and self-service ready project.
The configuration files must be saved separately and will be needed
whenever Terraform is run. If multiple people will be running the
Terraform commands then the config files will need to be shared.*

**Warning: the combination of backend (`$name.conf`) and config
(`$name.yml`) is significant. When running Terraform is it important
to treat them as a pair and to always use the same backend and config
together. To that end it is preferable (though not required) to use
matching filenames as in the examples.**

## Outputs

```bash
terraform output # all except "sensitive" values
terraform output ssh_private_key # display the private key

# or, if you're using AWS profiles to handle multiple accounts
AWS_PROFILE=$profile terraform output
```

## Multiple stacks

To create multiple stacks you simply need another pair of configuration
files. The backend config can mostly be the same, only a new `key` is
required:

```hcl
# dev1.conf
bucket  = "mybucket"
key     = "basic-stack1.tfstate"
region  = "us-west-2"
encrypt = true
# dev2.conf
bucket  = "mybucket"
key     = "basic-stack2.tfstate"
region  = "us-west-2"
encrypt = true
```
