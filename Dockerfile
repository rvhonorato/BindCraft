#=======================================================================================================================================================#
ARG CUDA=12.8.0
FROM nvidia/cuda:${CUDA}-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

#=======================================================================================================================================================#
# Install system dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential=12.9ubuntu3 \
  ca-certificates=20240203~22.04.1 \
  git=1:2.34.1-1ubuntu1.12 \
  wget=1.21.2-2ubuntu1.1 \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#=======================================================================================================================================================#
# Setup Miniconda
RUN wget -q -P /tmp \
  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
  bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
  rm /tmp/Miniconda3-latest-Linux-x86_64.sh

ENV PATH /opt/conda/bin:$PATH

RUN conda create -n bindcraft python=3.10 -y

ENV PATH /opt/conda/envs/bindcraft/bin:$PATH

#=======================================================================================================================================================#
# Install ColabDesign
RUN pip install --no-cache-dir git+https://github.com/sokrypton/ColabDesign.git@v1.1.3 --no-deps

#=======================================================================================================================================================#
# Download AlphaFold2 weights
# NOTE: This will put the weights inside the container, which is not ideal but makes the execution simpler without needing to refactor the api
WORKDIR /opt/bindcraft/params
RUN wget --progress=bar:force:noscroll -O alphafold_params_2022-12-06.tar "https://storage.googleapis.com/alphafold/alphafold_params_2022-12-06.tar" && \ 
  tar -xvf alphafold_params_2022-12-06.tar /opt/bindcraft/params

#=======================================================================================================================================================#
# Setup BindCraft
WORKDIR /opt/bindcraft
COPY . .

# TODO: Make sure we are in the right tag here since its copying diretly from the host

RUN chmod +x "/opt/bindcraft/functions/dssp" && \
  chmod +x "/opt/bindcraft/functions/DAlphaBall.gcc"

# Install bindcraft dependencies
# NOTE: Would be better if this was not hardcoded here
RUN conda install \
  -c conda-forge \
  -c nvidia \
  -c https://conda.graylab.jhu.edu \
  -y \
  pip \
  pandas \
  matplotlib \
  numpy"<2.0.0" \
  biopython \
  scipy \
  pdbfixer \
  seaborn \
  libgfortran5 \
  tqdm \
  jupyter \
  ffmpeg \
  pyrosetta \
  fsspec \
  py3dmol \
  chex \
  dm-haiku \
  flax"<0.10.0" \
  dm-tree \
  joblib \
  ml-collections \
  immutabledict \
  optax \
  jaxlib \
  jax \
  cuda-nvcc \
  cudnn 

# DONE

#=======================================================================================================================================================#

