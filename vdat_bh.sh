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
# !/bin/bash

if [[ -e $1 && $1 =~ .*\.msi$ ]]; then
  echo "Extracting $1"

  # create a temporary directory and delete on exit
  VDAT_TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$VDAT_TEMP_DIR"' EXIT

  # copy the Fathom Connect installer to the temp directory
  cp $1 $VDAT_TEMP_DIR/fathom_connect.msi

  # Pull out vdat.exe from the Fathom Connect installer
  ## --rm -> remove container after run
  ## -v -> mount temporary directory to /VDAT in container
  ## ghcr.io/trackyverse/vdat sh -c -> run the following commands in a shell
  ##    within the container
  ## msiextract fathom_connect.msi > /dev/null -> extract the .msi file and 
  ##    suppress output
  ## mv Innovasea/Fathom\ Connect/vdat.exe /VDAT/vdat.exe -> move the extracted
  ##    vdat.exe file to the mounted directory

  docker run --rm \
    -v $VDAT_TEMP_DIR:/VDAT \
    ghcr.io/trackyverse/vdat sh -c \
      "msiextract fathom_connect.msi > /dev/null; \
      mv Innovasea/Fathom\ Connect/vdat.exe /VDAT/vdat.exe;
      rm -rf Innovasea"

  # copy vdat.exe to current directory
  # cp $VDAT_TEMP_DIR/vdat.exe .
  cp "$VDAT_TEMP_DIR/vdat.exe" "$VDAT_DIR/"

  # clean up temporary directory
  rm -rf $VDAT_TEMP_DIR

  # echo "vdat.exe extracted to $PWD"
  echo "vdat.exe copied to $VDAT_DIR"
# If the first argument is not an MSI, run vdat.exe with Wine 
else

  # Check that vdat.exe exists in the current directory
  if [[ ! -e "$VDAT_DIR/vdat.exe" ]]; then
    echo -e "vdat.exe not found in current directory."
    exit 1
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

fi