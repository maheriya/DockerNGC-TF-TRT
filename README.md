## What is DockerNGC-TF-TRT
The Dockerfile in this repo builds a Docker image on top of NGC TensorFlow-TensorRT container with some user level packages added. It also allows you to use the NGC docker as a normal user including sudo access. I have also added some extra packages via requirements.txt. You may choose not to install those extra packages by commenting out the line containing requirements.txt in the Dockerfile.

## Installation
There are two steps: first we set up Nvidia related stuff, and then we build our own docker wrapper.

### Nvidia Related Setup
You will need an account on Nvidia GPU Cloud (NGC) platform. It is free. We will be using it only to access the NGC docker containers. If you don't have one, read this [Getting Started](https://docs.nvidia.com/ngc/ngc-getting-started-guide/index.html) guide for using NGC.

Main thing is to create and account and create and API key. Once you have the account, [generate API Key](https://docs.nvidia.com/ngc/ngc-getting-started-guide/index.html#generating-api-key).

#### Login to nvcr.io
```shell
docker login nvcr.io
Username: $oauthtoken
Password: <your API key>
```

The $oauthtoken is the actual user name. Type it exactly including the '$' sign.

Before building this docker image, first try to download and run the vanila NGC docker and run it as below:

Pull NGC docker image:
```shell
docker pull nvcr.io/nvidia/tensorflow:19.05-py2
```

Run it:
```shell
nvidia-docker run -it --rm nvcr.io/nvidia/tensorflow:19.05-py2
```

If everything works fine, move on to building the custom docker image using the Dockerfile in this repo.

### Custom Docker
Now let's build the custom docker container image.

Note: Please change user id to your own (or remove it) in the Dockerfile. You really only need the numeric uid and gid. I have not cleaned up the Dockerfile for this aspect yet.

```shell
cd <this repo dir>
docker build -t ngc-gpu/tf-trt:py2 .
```

Once the image is built, you can run it just like we ran the NGC image. However, to abe able to use this container like the normal user, you need to add a few options while running the image. The file 'aliases' has some csh/tcsh aliases that you can use to run the image. For others, here is the complete command line that I use to run this container:

```shell
nvidia-docker run -it --rm                              \
        -p 8888:8888 -p 6006:6006                       \
        --shm-size=1g --ulimit memlock=-1               \
        --group-add sudo                                \
        --env="DISPLAY"                                 \
        --volume="/etc/group:/etc/group:ro"             \
        --volume="/etc/passwd:/etc/passwd:ro"           \
        --volume="/etc/shadow:/etc/shadow:ro"           \
        --volume="/etc/sudoers.d:/etc/sudoers.d:ro"     \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"     \
        --volume="/home/${USER}:/home/${USER}"          \
        --volume="/IMAGESETS:/IMAGESETS"                \
        --ipc=host                                      \
        --user ${uid}:${uid}                            \
        ngc-gpu/tf-trt:py2
```

Why Run it like that? Well, here is a list of advantages:
- With --volume option, you can access all those directories as you would from non-container access including user permissions. For example, I have mapped `/home/${USER}` and `/IMAGESETS` directories that I need to access from within the container.
- The user id will match the regular user id. For example, my user id is 'maheriya' on my Linux work station. I retain my home directory even within the container.
- Retain sudo access (if normal user had sudo access).
- the --shm-size and --ulimit line removes certain restrictions that are enabled on certain systems


