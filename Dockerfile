FROM pytorch/pytorch:2.1.1-cuda12.1-cudnn8-devel

ARG PIP_CONF="LLM_training_docker/config"

# set timezone
ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        curl \
        wget \
        vim \
        git \
        fish \
        zip \
        unzip \
	sudo

# Fix import cv2 error
RUN apt install libgl1-mesa-glx -y 
RUN apt-get install libglib2.0-0 -y

# Create a new user
ARG UID
ARG GID
ARG GROUP
ARG HOME
ARG USERNAME
ARG PASSWORD
ENV USERNAME=$USERNAME

RUN groupadd -g ${GID} ${GROUP} && \
    useradd -m ${USERNAME} --uid=${UID} --gid=${GID} && \
    echo "${USERNAME}:${PASSWORD}" | chpasswd && \
    adduser ${USERNAME} sudo

WORKDIR /workspace
RUN echo "Current working directory:" $(pwd)

# Switch to the new user
RUN chown -R docker:docker /workspace
# RUN mkdir -p /home/${USERNAME}/.cache/huggingface
# RUN chown -R docker:docker /home/${USERNAME}/.cache/huggingface

USER ${USERNAME}
USER ${UID}:${GID}

# Fix "jupyter: command not found"
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

# Install python dependency
COPY ${PIP_CONF}/requirements.txt /tmp
RUN python3 -m pip install -U pip
RUN python3 -m pip install -r /tmp/requirements.txt
# RUN rm -r /tmp

RUN jupyter contrib nbextension install --user && \
    jupyter nbextensions_configurator enable --user && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter nbextension enable autosavetime/main 

