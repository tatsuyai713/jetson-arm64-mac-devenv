# NVIDIA JetPack Image Container
 This docker file makes the container for NVIDIA JetPack on M1 Mac (ARM64).
## Limitation
 This Docker file support only arm64 based Mac.
## How to use
1. Install docker desktop for M1 Mac
2. Download NVIDIA JetPack 5.02
3. Make tarball from image file.
4. docker image import ~/jetson_docker_image.tar jetson_docker_image:latest
5. Excute "./launch_container.sh setup"
6. Usually use "./launch_container.sh"
7. If you want to commit docker container, please use "./launch_container.sh commit"
8. Turn off Mac Remote Login. (ssh server)
9. Check the ssh connection from host. (ssh nvidia@localhost)
