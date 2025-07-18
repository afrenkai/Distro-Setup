#!/bin/bash

set -e

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists curl && command_exists wget; then
  echo "curl is not installed. doing wget"
  wget -qO- https://astral.sh/uv/install.sh | sh
elif command_exists curl; then
  echo "curl is on system, using recommended astral install with curl"
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "no wget or curl"
  exit 1
fi

echo "uv installed"

#make sure we can talk to gpu, and set up torch with a sample uv proj

if ! command_exists nvidia-smi; then
  echo "no nvidia-smi"
  exit 1
fi

if ! command_exists nvcc; then
  echo "no nvcc"
  exit 1
fi

if ! test -d ".venv"; then
  uv venv
fi

source .venv/bin/activate

uv pip install -r requirements.txt

echo "Checking cuda compute capability... ..."
GPU_CHECK_OUTPUT=$(uv run check_cuda.py 2>&1)
echo "$GPU_CHECK_OUTPUT"
if echo "$GPU_CHECK_OUTPUT" | grep -iq '\bno\b'; then
  echo "No GPU detected. Training will use CPU (this will be slow)."
  DEVICE="cpu"
elif echo "$GPU_CHECK_OUTPUT" | grep -iq '\byes\b'; then
  echo "Cuda Compute Capable GPU found, training will use Cuda Backend"
  DEVICE="cuda"
fi
