# terraform-project-1

 - Write Terraform code to create the following:

     - Create an s3 bucket - test_bucket
     - Assume that given a VPC ID - create 2 subnets - subnet_1 and subnet_2 - choose any cidr
     - Create a policy which gives EC2 write access to test_bucket - test_policy
     - Create a role to which test_policy is attached - test_role
     - Create a security group which allows all incoming 443 and all outgoing internet traffic - test_sg_1
     - Create an ELB with health check - /health on port 443 of the instances behind it - test_elb
     - Create an EC2 instance with - subnet_1, test_role and test_sg_1 and add it to test_elb - choose any EC2 instance type. Think of what best practices you would use to create this instance.
     - Tag all of the above infra with key "product_id" value "test_product"
     - Save state in S3 - use a bucket name that you think would make sense.

   - Abstract the above code in a Terraform module

   - Write and version your module in such a way that the same module can be used to deploy to 3 environments - dev, stage and prod by just changing the variables.

   - Your code should pass the "terraform plan" phase. You don't need to do "terraform apply" on it.

   - Evaluation criteria:

     - Modularity of code.
     - Ease of understanding of README.md documentation.
     - Proper naming conventions.
     - How production ready your code is.
