# Creating a VPC on AWS using Terraform.
The work in this repo  is used to setup a Virtual Private Cloud and deploy [eight.one](https://github.com/silaskenneth/eight.one) to AWS.

[Creating Amazon Machine Images](https://github.com/SilasKenneth/ansible_packer)

## Requirements
  - [Terraform](https://www.terraform.io)

## Steps
First off, we copy the `terraform.tfvars.example` to a new file `terraform.tfvars` since this is where we store out environment variables/secrets.

To be able to create a network image we first need to create a machine image using packer so as to add the AMI to the `terraform.tfvars` file.

> **Note**
The instructions [Here](https://github.com/SilasKenneth/ansible_packer) would help guide in creating AMIs.

Once we have an image, we replace the following placeholders in the `terraform.tfvars` file with the values from our AWS account. We add our secret Key and Secret Id inside the file.

```bash
secret_id="<AMAZON_SECRET_ID>"
ami_id="<AMI_ID>"
secret_key="<AMAZON_SECRET_KEY>"
nat_instance_ami="<AMI_ID_FOR_NAT_INSTANCE>"
back_end_ami="<AMI_FOR_FRONT_END>"
front_end_ami="<FRONT_END_AMI>"
```

Once the setup is complete, we just run `terraform plan` to plan on how the changes would be applied to the infrastructure.
After that we run `terraform apply` to apply the changes to AWS.

And with that, we have our private network with all the instances. We navigate to instances and enter the IP address of the frontend to access the FronteEnd of the application.
To confirm the resources, go to the AWS console
#### How to destroy resources.
To destroy the resources, just run `terraform destroy` then input `yes` to confirm that you want to destroy the resources.


