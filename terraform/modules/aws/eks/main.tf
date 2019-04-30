
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.37.0"

  name = "${var.cluster-name}-vpc"
  cidr = "10.0.0.0/16"

  enable_nat_gateway = true

  azs             = ["us-east-1a", "us-east-1b", "us-east-1d"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    terraform = "true"
    "user.tag" = "legion"
    project = "legion"
    cluster_name = "${var.cluster-name}"
  }
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "3.0.0"

    cluster_name = "${var.cluster-name}"
    vpc_id       = "${var.vpc_id}"
    subnets      = "${module.vpc.private_subnets}"

    worker_groups = [
        {
            instance_type = "m4.xlarge"
            asg_max_size  = 5
        }
    ]

    tags = {
        vendor      = "legion"
        project     = "legion"
        env_name    = "${var.cluster-name}"
    }

    cluster_create_security_group = "true"

}
