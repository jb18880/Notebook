apt -y install ansible
cat >> /etc/ansible/hosts << EOF
[webservers]
10.0.0.8
EOF
sed -i  's/#host_key_checking = False/host_key_checking = False/' /etc/ansible/ansible.cfg
sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/' /etc/ssh/ssh_config
ssh-keygen
ssh-copy-id 10.0.0.8
ansible 10.0.0.8 -m ping
