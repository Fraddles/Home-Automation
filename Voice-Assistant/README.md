*Details about my Voice-Assistant setup for Home Assistant*

<random notes>
Install Debian with usuals;
- No root password, initial user...
- Add 'contrib' and 'non-free' to the repos after install

sudo apt update
sudo apt install linux-headers-amd64 firmware-misc-nonfree
? sudo apt full-upgrade

###  Add docker...  https://docs.docker.com/engine/install/debian/#install-using-the-repository
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources: ### fix for 'testing'
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

###  NVIDIA drivers and stuff... 
sudo apt install nvidia-driver nvidia-smi nvidia-settings nvidia-cuda-toolkit nvidia-cudnn ###can do container toolkit from repo?###
reboot

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
docker run --gpus all nvidia/cuda:12.1.1-runtime-ubuntu22.04 nvidia-smi 
###  WORKS!!!
