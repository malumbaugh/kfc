# remove any docker installed as part of the OS
echo "=== Removing older modules - docker, docker.io, containerd"
sudo apt-get remove docker docker-engine docker.io containerd runc

echo "=== Updating and installing required modules"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release tree

echo "=== Adding Docker GPG key and Google Cloud Public signing key"
# add docker official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add the Google Cloud Public signing Key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "=== Adding Docker repository and kubernetes repository"
# Add the docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Add the kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

echo "=== Update and install docker containerd tree kubelet kubeadm kubectl"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "=== Configure containerd"
#Configure containerd  - Try this on second pass 
#  More Info here https://kubernetes.io/docs/setup/production-environment/container-runtimes/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

echo "=== Add users to docker group to run docker commands "
# Allow users to do docker commands without sudo
sudo groupadd docker
sudo usermod -aG docker $USER

echo "=== Setup self signed certs "
sudo mkdir -p /etc/docker/certs.d/sa-master-01.vclass.local:443
sudo scp -o "StrictHostKeyChecking no" ubuntu@172.20.10.31:/certs/domain.crt /etc/docker/certs.d/sa-master-01.vclass.local:443


echo "=== Setup systemd daemon"
# Setup systemd daemon.
sudo touch /etc/docker/daemon.json
sudo chmod 666 /etc/docker/daemon.json
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo chmod 600 /etc/docker/daemon.json

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

