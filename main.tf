module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0b662aa0c0e89cf46"] #replace your SG
  subnet_id = "subnet-04cbcc7076c9b61c6" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins"
  }

  # Define the root volume size and type
  root_block_device = {
      volume_size = 50       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0b662aa0c0e89cf46"] #replace your SG
  subnet_id = "subnet-04cbcc7076c9b61c6" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")
  tags = {
    Name = "jenkins-agent"
  }

  root_block_device = {
      volume_size = 50       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
}

# resource "aws_ebs_volume" "jenkins_agent_disk" {
#   availability_zone = "us-east-1d"  # Match your instance's AZ
#   size              = 5
#   type              = "gp3"
#   tags = {
#     Name = "jenkins-agent-disk"
#   }
# }

# resource "aws_volume_attachment" "jenkins_agent_attach" {
#   device_name = "/dev/sdf"
#   volume_id   = aws_ebs_volume.jenkins_agent_disk.id
#   instance_id = module.jenkins_agent.id
# }


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    }
  ]

}