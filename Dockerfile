FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime
ENV DEBIAN_FRONTEND=noninteractive 

# RUN apt-get update \
#  && apt-get install -y --no-install-recommends \
#  libxcursor-dev \
#  libxrandr-dev \
#  libxinerama-dev \
#  libxi-dev \
#  mesa-common-dev \
#  zip \
#  unzip \
#  make \
#  gcc-8 \
#  g++-8 \
#  vulkan-utils \
#  mesa-vulkan-drivers \
#  pigz \
#  git \
#  libegl1 \
#  git-lfs

# # Force gcc 8 to avoid CUDA 10 build issues on newer base OS
# RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8
# RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8

# WAR for eglReleaseThread shutdown crash in libEGL_mesa.so.0 (ensure it's never detected/loaded)
# Can't remove package libegl-mesa0 directly (because of libegl1 which we need)
# RUN rm /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0 /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0.0.0 /usr/share/glvnd/egl_vendor.d/50_mesa.json

# COPY docker/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
# COPY docker/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# RUN useradd --create-home gymuser
# USER gymuser

# copy gym repo to docker
# COPY --chown=gymuser . .

# install gym modules
# ENV PATH="/home/gymuser/.local/bin:$PATH"
# RUN cd python && pip install -q -e .

ENV NVIDIA_VISIBLE_DEVICES=all NVIDIA_DRIVER_CAPABILITIES=all

RUN conda create --name aloha python=3.8.10 && \
    echo "source activate aloha" > ~/.bashrc

# Set the PATH for the new environment
ENV PATH /opt/conda/envs/aloha/bin:$PATH

# Change the current directory to your Python project directory

# # Install your Python project
# RUN /opt/conda/envs/aloha/bin/python -m pip install  -e .
# WORKDIR /isaacgymcore_envs
# RUN /opt/conda/envs/aloha/bin/python -m pip install  -e .

# Install libpython3.8
USER root
# RUN apt-get update && apt-get install -y libpython3.8
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git


# WAR for eglReleaseThread shutdown crash in libEGL_mesa.so.0 (ensure it's never detected/loaded)
# Can't remove package libegl-mesa0 directly (because of libegl1 which we need)
# RUN rm /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0 /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0.0.0 /usr/share/glvnd/egl_vendor.d/50_mesa.json

# COPY nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
# COPY 10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# RUN apt-get update \
#  && apt-get install -y --no-install-recommends \
#  libxcursor-dev \
#  libxrandr-dev \
#  libxinerama-dev \
#  libxi-dev \
#  mesa-common-dev \
#  zip \
#  unzip \
#  make \
#  gcc-8 \
#  g++-8 \
#  vulkan-utils \
#  mesa-vulkan-drivers \
#  pigz \
#  git \
#  libegl1 \
#  git-lfs

RUN /opt/conda/envs/aloha/bin/python -m pip install \
    torchvision \
    torch \
    pyquaternion \
    pyyaml \
    rospkg \
    pexpect \
    mujoco \
    dm_control \
    opencv-python \
    matplotlib \
    einops \
    packaging \
    h5py \
    ipython

# WORKDIR act-plus-plus/detr
COPY detr /detr
WORKDIR /detr
RUN /opt/conda/envs/aloha/bin/python -m pip install -e .

RUN apt-get update && apt-get install -y libglib2.0-0

# Set the working directory
WORKDIR /tempdir

# Uninstall robomimic if it's installed
RUN pip uninstall -y robomimic
RUN git clone https://github.com/ARISE-Initiative/robomimic.git

# Change into the robomimic directory and checkout the desired branch
WORKDIR /tempdir/robomimic
RUN git checkout diffusion-policy-mg

# Install robomimic and diffusers
RUN pip install -e . && pip install diffusers
