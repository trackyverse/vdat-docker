# Innovasea's VDAT and trackyverse R packages on macOS and Linux

The helper file contained within this repository (`vdat.sh`) aims to provide access to Innovasea's VDAT executable via a Docker container. This allows users to run VDAT on macOS and Linux systems, where it is not natively supported.

## Installation Instructions
1. Download Fathom Connect from [Innovasea's Download page](https://support.fishtracking.innovasea.com/s/downloads).
2. Download the `vdat.sh` script from this repository into the same directory.
3. Install Docker
  - [macOS](https://docs.docker.com/desktop/install/mac-install/)
  - [Linux](https://docs.docker.com/engine/install/)
4. Open a terminal and pull the VDAT Docker image: `docker pull ghcr.io/trackyverse/vdat:latest` 
5. In the terminal, navigate to the directory where you downloaded the Fathom Connect installer and `vdat.sh` script.
6. Make the helper script executable: `chmod +x vdat.sh`
7. Run the helper script with the Fathom Connect installer as an argument: `./vdat.sh Fathom_Installer.msi`. This will extract `vdat.exe` from the installer and place it in the same directory.

## Using VDAT!

You can now run VDAT using the helper script. For example, to see the available commands, run: `./vdat.sh --help`.
