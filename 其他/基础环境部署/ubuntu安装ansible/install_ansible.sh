apt -y install ansible
cat >> /etc/ansible/hosts << EOF
[webservers]
192.168.10.10
EOF
sed -i  's/#host_key_checking = False/host_key_checking = False/' /etc/ansible/ansible.cfg
sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/' /etc/ssh/ssh_config
ssh-keygen
ssh-copy-id 192.168.10.10  
ansible 192.168.10.10 -m ping
