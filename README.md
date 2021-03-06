The purpose of this project was to create a SDN security system. 
The project is supposed to be deployed using both repositories from:
- https://github.com/chrissayon/sdn_security_platform_frontend
- https://github.com/chrissayon/sdn_security_platform_backend

The repository however will provision the whole infrastructure automatically using Terraform and Ansible onto AWS.

## How this whole project functions: 
Provided you already know about SDN architecture, the backend of this project periodically pings a OpenFlow controller and gets statistics from the exposed controller API. It takes this data and performs so calculations to get periodic/incremental data and also runs the data through a machine learning model to check for DDoS attacks. It also runs the data through a machine learning model which was developed using TensorFlow 2.0 in python which will give a probability of whether the network is being attacked or not (though as byte count is the metric then this means that the scale of the network needs to be taken into account on whether the network is being attacked).

The original code was designed so that he frontend would ping localhost which would be hosting he backend. If you want to see this website working in full functionality then install and run the frontend and backend on the same host; or you could alternatively run the frontend on the EC2 instance which would try to ping the backend on your local computer which you're accessing the browser from. Otherwise, you will just see the frontend interface with no functionality

The provisioning repository is able to deploy both the code to both frontend and backend on seperate hosts, but with the way the code is designed you won't get the full functionality if you run them on seperate hosts. The SDN Security Platform provision is more of a way for to demonstrate my DevOps skills and I was using this project as a means to do that.

## Requirements:
- Terraform should already be installed on your computer
- Python 3 should be already be installed on your computer
- Python 3 libraries: ansible, and boto
- AWS cli installed and already preconfigured with your credentials


## Provisioning
1. Change directories into the Terraform folder
2. Run the following commands: 
##### terraform init
##### terraform apply
These commands will initialize and deploy your resources to aws

## Configuring
1. Change directories into the Ansible folder 
2. Run the command:
##### ansible-playbook -i ec2.py main.yml
You may get an execution error with the line "/usr/bin/env: ‘python\r’: No such file or directory". As the file was edited under windows, it has the CR LF line seperator; Unix does not have this. To fix this issue, install dos2unix and execute:
##### dos2unix ec2.py

## Other
Everything should be provisioned with these two commands. You can type the website IP address and you should see the websites being hosted.

A SSH key will be generated inside the terraform folder called "web_server_key.pem" which you can use to ssh into the instances. The username that should be used is "ubuntu"

## Cleanup
1. Change directories into the Terraform folder
2. Run the following command:
##### terraform destroy

This command will desroy all the resources that you've hosted.
