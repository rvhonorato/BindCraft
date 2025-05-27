# ==============================================================================
ARG CUDA=12.8.0
FROM nvidia/cuda:${CUDA}-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential=12.9ubuntu3 \
  ca-certificates=20240203~22.04.1 \
  git=1:2.34.1-1ubuntu1.12 \
  wget=1.21.2-2ubuntu1.1 \
  bzip2=1.0.8-5build1 \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN wget -q -P /tmp \
  https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
  && rm /tmp/Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/opt/conda/bin:$PATH"
ENV LD_LIBRARY_PATH="/opt/conda/lib:$LD_LIBRARY_PATH"

WORKDIR /opt/bindcraft
COPY . .

RUN bash install_bindcraft.sh

ENV PYTHONPATH="/opt/bindcraft:$PYTHONPATH"

# ==============================================================================
