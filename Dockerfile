# set base image (host OS)
#FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04
#FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-devel
#FROM pytorch/pytorch:1.13.0-cuda11.6-cudnn8-devel
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime

# set and add the working directory in the container
WORKDIR /conda_pytorch_docker
ADD . /conda_pytorch_docker
COPY pytorch.yml .

# Set environment and arg variables.
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

# Since wget is missing
RUN apt-get update --allow-insecure-repositories 
RUN apt-get install -y wget gcc

#Install MINICONDA
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh
 
# Install gcc as it is missing in our base layer
#RUN apt-get update && apt-get -y install gcc 

# Create a conda environment based on the environment.yml file
RUN conda env create -f pytorch.yml

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "pytorch", "/bin/bash", "-c"]

RUN python -m nltk.downloader all 

# Make sure the environment is activated:
RUN echo "Make sure flask is installed:"
RUN python -c "import flask"

EXPOSE 5000

RUN conda init bash 

# The code to run when container is started:
#ENTRYPOINT ["bash"]

# Add the correct user
ARG UID=1000
ARG GID=1000

RUN groupadd -g "${GID}" python \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" python

USER python
