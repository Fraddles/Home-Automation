*Random notes and details about my Voice-Assistant setup for Home Assistant*

# Wyoming-Whisper in Docker with Nvidia GPU support.
This was setup on a fresh install of Debian 12 Testing (Trixie) on an old Dell minitower with an i5-3550, 16GB RAM and an Nvidia GTX-1070.
#### Install OS;
- No root password, initial user with `sudo`
- Ensure to install `SSH server` package/role

*After initial install do some updates and cleanup;*
- Add 'contrib' and 'non-free' to the repos, comment out the 'DVD' repo if it is there
- Update the repo cache `sudo apt update`
- Upgrade any packages that need it `sudo apt upgrade`
### Add docker...  https://docs.docker.com/engine/install/debian/#install-using-the-repository
*Add Docker's official GPG key:*
```
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
*Add the repository to Apt sources, need to fix for Debian 'testing', and install Docker*
```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
###  NVIDIA drivers and stuff...
Need to install Nvidia driver, CUDA and tools, these can be installed from Debian 12 Testing repo... YMMV if you are using a different distro.
```
sudo apt install nvidia-driver nvidia-smi nvidia-settings nvidia-cuda-toolkit nvidia-cudnn ###can do container toolkit from repo?###
```
Now we can add the nvidia container toolkit, which is installed from Nvidia;
```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update
sudo apt install nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Test
```
docker run --gpus all nvidia/cuda:12.1.1-runtime-ubuntu22.04 nvidia-smi
```
Assuming that the test works, you can now move onto firing up the Wyoming-Whisper Docker container...

The attached `docker-compose.yaml` should succesfully run up the container with GPU support.  This service can then be added to Home-Asisstant using the hostname of the server and port 10300.  
Currently my Home Assistant and GPU enabled Whisper are running on different servers without any apparent performance or lag issues.

### NOTES:
- When I first added the new Whisper integration to HA I found that I had two seemingly identical integrations. the new one and the original one running on the HA server.  You can assign unique names to them after they are added to HA.
- You can validate the improvment in performance by removing the `--device cuda` from the command and relaunching the container, this will cause it to use CPU rather than GPU.
- It was neccessary to map some additional libraries into the container to resolve some errors.  Without these libraries the container would start, but crash out as soon as any STT was required.  These libraries are part of the `nvidia-cudnn` package.

CPU | GPU
--- | ---
 [image here] | ![image](https://github.com/Fraddles/Home-Automation/assets/65753186/44aac459-8d4c-4f93-a5b9-dfd4dfb32025)


