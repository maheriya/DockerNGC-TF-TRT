## NGS TensorFlow + TensorRT
## Must use Python2 because TF Object detection API still uses code not compatible with Python3
FROM nvcr.io/nvidia/tensorflow:19.05-py2

## Run TensorFlow image as normal user (maheriya)
##FROM ubuntu:16.04
RUN groupadd --gid 1000 maheriya
RUN useradd  -r --uid 1000 --gid maheriya maheriya
RUN apt-get update
## Install my preferred apps
RUN apt-get install -y sudo vim csh tcsh
RUN pip install tqdm
## Facenet dependencies
RUN apt-get install -y libsm6 libxext6 libxrender-dev
RUN apt-get install -y python-tk


### Set the working directory to /app
WORKDIR /app
### Copy the current directory contents into the container at /app
COPY . /app
### Install any needed extra packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt
RUN pip install --trusted-host pypi.python.org keras
RUN pip install --trusted-host pypi.python.org Cython
RUN pip install --trusted-host pypi.python.org lxml contextlib2
RUN pip install --trusted-host pypi.python.org jupyter


USER maheriya
# Make certain ports available to the world outside this container
EXPOSE 8888
EXPOSE 8080
EXPOSE 6006

# Define environment variable
ENV NAME "NGS-TF-TRT"

##
### Run shell when the container launches
##ENTRYPOINT ["sleep", "infinity"]
CMD ["/bin/tcsh"]
