resource "aws_instance" "linux_server_1" {
  ami = "ami-076ccd3e4bdbbe88a"
  instance_type = "t3.medium"
  associate_public_ip_address = true
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [ aws_security_group.my-project-sg.id ]
  key_name = var.my_ssh_key
  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"

  # root disk
  root_block_device {
    volume_size = "30"
    volume_type = "gp2"
    encrypted = false
    delete_on_termination = true
  }

  user_data = "${data.template_file.script_server_1.rendered}"

  tags = {
    Name = "ubuntu-test-server-1"
  }
}

output "_01_linux_server_1_name" {
  value = aws_instance.linux_server_1.tags.Name
}

output "_02_linux_server_1_ip" {
  value = aws_instance.linux_server_1.public_ip
}

data "template_file" "script_server_1" {
  template = "${file("script-server-1.tpl")}"
}

# notes
#
# 
# miniconda installer script
# https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
#

