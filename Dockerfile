#=======================================================================================================================================================#
ARG CUDA=12.8.0
FROM nvidia/cuda:${CUDA}-cudnn-runtime-ubuntu22.04

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV DEBIAN_FRONTEND=noninteractive

#=======================================================================================================================================================#
# Install system dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  git \
  wget \
  python3-dev \ 
  python3-pip \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#=======================================================================================================================================================#
# Install PDBFixer
WORKDIR /opt
RUN git clone https://github.com/openmm/pdbfixer.git
WORKDIR /opt/pdbfixer
RUN uv pip install numpy --system && \
  python3 setup.py install

#=======================================================================================================================================================#
# Install PyRosetta
RUN uv pip install pyrosetta-installer --system && \
  python3 -c "import pyrosetta_installer; pyrosetta_installer.install_pyrosetta()"

#=======================================================================================================================================================#
# Download AlphaFold2 weights
# NOTE: This will put the weights inside the container, which is not ideal but makes the execution simpler without needing to refactor the api
WORKDIR /opt/bindcraft/params
RUN wget --progress=bar:force:noscroll -O alphafold_params_2022-12-06.tar "https://storage.googleapis.com/alphafold/alphafold_params_2022-12-06.tar" && \ 
  tar -xvf alphafold_params_2022-12-06.tar && \
  rm alphafold_params_2022-12-06.tar

#=======================================================================================================================================================#
# Install BindCraft
WORKDIR /opt/bindcraft
COPY . .

# NOTE: Would be better if this was not hardcoded here
RUN uv pip install --system \
  pandas \
  matplotlib \
  numpy"<2.0.0" \
  biopython \
  scipy \
  seaborn \
  tqdm \
  jupyter \
  ffmpeg \
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
  nvidia-cuda-nvcc-cu12 \
  nvidia-cudnn-cu12 \
  git+https://github.com/sokrypton/ColabDesign.git@v1.1.3 

WORKDIR /opt/bindcraft/functions

# TODO: Make sure we are in the right tag here since its copying diretly from the host
RUN chmod +x "/opt/bindcraft/functions/dssp" && \
  chmod +x "/opt/bindcraft/functions/DAlphaBall.gcc"

#=======================================================================================================================================================#
# Done
# TODO: Entrypoint?

#=======================================================================================================================================================#

