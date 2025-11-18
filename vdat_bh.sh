#
# THIS IS IT! It works  
# !/usr/bin/env bash
# set pipe fail 
set -euo pipefail

#set vdat director as home directory with /vdat 
VDAT_DIR="$HOME/vdat"
# === CONFIG ===
# make this diroector if it doesn't exist if it does skip i 
if [[ ! -d "$VDAT_DIR" ]]; then
  mkdir -p "$VDAT_DIR"
fi
# get the full path to vdat 
VDAT_FULL_PATH="$(cd "$VDAT_DIR" && pwd)/vdat.exe"

# Check if vdat.exe exists
if [[ ! -f "$VDAT_FULL_PATH" ]]; then
  echo "ERROR: vdat.exe is missing at '$VDAT_FULL_PATH'"
  exit 1
fi

# Detect host architecture
HOST_ARCH=$(uname -m)
DOCKER_PLATFORM=""
if [[ "$HOST_ARCH" == "aarch64" || "$HOST_ARCH" == "arm64" ]]; then
  DOCKER_PLATFORM="--platform linux/amd64"
fi
# create things to mount as blank 
THINGS_TO_MOUNT=""
 # Base command to run vdat.exe with Wine
  # ${*:1} grabs all arguments passed to the script
VDAT_ARGS="${*:1}"

# when arg equals inspect 
if [[ "$1" == "inspect" ]]; then
    if [[ $# -lt 2 ]]; then
        echo "ERROR: inspect requires a file path"
        exit 1
    fi
    # input file is secnod arg 
    INPUT_FILE="$2"
    # create baseanem of where input files need to go 
    BASENAME=$(basename "$INPUT_FILE")
    # get the full path 
    ABS_DIR="$(cd "$(dirname "$INPUT_FILE")" && pwd)"

    # IMPORTANT: no quotes inside the -v argument
    # mount files to this absolute diroctry - right now it takes the base dircorty of the file 
    # and mounts all files in that dirctory which may not be ideal - make the container large 
    THINGS_TO_MOUNT="-v $ABS_DIR:/input"
    # we need to get the ine path which will be z and then give it base name to be able to find 
    # where the files are 
    WINE_PATH="Z:/$(echo "/input/$BASENAME")"
    # Modify Wine command so file is inside container
    # now ew can use inpsect with the path to wine with where the files are mounted 
    # in this case they are mounted in input but we can change that to vdat in the container 
    VDAT_ARGS="inspect $WINE_PATH"
fi
# now run vdat commd with mvk log set to 0 and winbug all and $$vdat args 
VDAT_CMD="MVK_CONFIG_LOG_LEVEL=0 WINEDEBUG=-all wine /vdat/vdat.exe $VDAT_ARGS"

# no use docker run  - the echo at the end will show us both what we can do with thefiles that are mounted
# read/write ect. and if hey are in the container 
docker run --rm \
  $DOCKER_PLATFORM \
  -v "$(dirname "$VDAT_FULL_PATH")":/vdat \
  $THINGS_TO_MOUNT \
  ghcr.io/trackyverse/vdat \
  sh -c "echo 'Listing /input:'; ls -l /input; echo 'Running:'; echo $VDAT_CMD; $VDAT_CMD"

