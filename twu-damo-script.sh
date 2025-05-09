#!/bin/sh

# Ensure script fails on any error
set -Eeo pipefail
trap 'echo "[ERROR] Something went wrong!! Please check output above!!" >&2' ERR

# Check if the script is being piped
# if [ -t 0 ]; then
#     echo "This script should be run using curl:"
#     echo "curl -sSL https://raw.githubusercontent.com/thoughtworks-twu/setup-script/main/update_twu_script.sh | sh -s -- -dev"
#     exit 1
# fi

JAVA_VERSION=17
NODE_VERSION=18
CERT_FILE_NAME=letsencrypt-stg-root-x1.pem
CERT_FILE_FOLDER=~/.local/share/certs
CERT_FILE_LOCATION=$CERT_FILE_FOLDER/$CERT_FILE_NAME
wereErrors=false

installHomebrew() {
    printf "Checking Homebrew status...\n"
    command -v brew > /dev/null
    status=$?
    if [ $status == 0 ]; then
        printf "Homebrew is already installed.\n"
    else
        logMessage "Installing Homebrew...\nYou may be prompted for your password"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ $(sysctl -n machdep.cpu.brand_string) =~ "Apple" ]]; then
          echo "eval $(/opt/homebrew/bin/brew shellenv)" >> "${HOME}"/.zprofile
          eval "$(/opt/homebrew/bin/brew shellenv)"
          logOkMessage "Homebrew installation complete."
        else
          logOkMessage "Homebrew installation complete."
        fi
    fi
}

installGit() {
    logMessage "Installing Git..."
    brew install git
    logOkMessage "Git installation complete."
}

installJava() {
    logMessage "Installing Java..."
    brew install openjdk@$JAVA_VERSION
    sudo ln -sfn "$(brew --prefix)"/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
    logOkMessage "Java installation complete."
}

installNode() {
    logMessage "Installing Node.js..."
    brew install node@$NODE_VERSION
    brew link --overwrite node@$NODE_VERSION
    logOkMessage "Node.js installation complete."
}

installColima() {
    logMessage "Installing Colima..."
    brew install colima
    logOkMessage "Colima installation complete."
}

installDockerCLIandCompose() {
    logMessage "Installing Docker CLI and Compose tools..."
    brew install docker docker-compose
    logOkMessage "Docker CLI and Compose tools installation complete."
}

installRancher() {
    logMessage "Installing Rancher..."
    brew install --cask rancher
    logOkMessage "Rancher installation complete."
}

installYarn() {
    logMessage "Installing Yarn..."
    brew install yarn
    logOkMessage "Yarn installation complete."
}

logMessage() {
    bold=$(tput bold)
    normal=$(tput sgr0)

    printf '\n\n'
    printf '%.0s-' {1..50}
    printf "\n${bold}$1${normal}\n"
    printf '%.0s-' {1..50}
    printf '\n'
}

logError() {
    red='\033[0;31m'
    normal='\033[0m'

    printf '\n'
    printf "${red}[ERROR] $1${normal}\n"
    printf '\n'

    wereErrors=true
}

logOkMessage() {
    green='\033[0;32m'
    normal='\033[0m'

    printf '\n'
    printf "${green}[OK] $1${normal}\n"
    printf '\n'
}

verifyJavaVersion() {
    logMessage "Verifying Java"
    echo "Checking Java version is correct..."
    current_java_version=`java -version 2>&1 | head -n 1 | cut -d'"' -f2 | xargs`
    required_java_version='17'

    if  [[ $current_java_version == $required_java_version* ]] ; then
        logOkMessage "Current Java version: "$current_java_version
    else
        logError "Java version is not ${required_java_version}. Please follow the pre-TWU setup documentation to update JAVA_HOME path."
    fi
}

verifyNodeVersion() {
    logMessage "Verifying Node.js"
    echo "Checking Node.js version is correct..."
    current_node_version=`node --version | sed 's/v\([0-9]*\).*/\1/; 1q'`

    if [[ $current_node_version == $NODE_VERSION ]]; then
        logOkMessage "Current Node.js version: "$current_node_version
    else
        logError "Node.js version is set to ${current_node_version} and not ${NODE_VERSION} as required. If you're using nvm (or similar) make sure to set it to version ${NODE_VERSION}."
    fi
}

verifyGit() {
    logMessage "Verifying Git"
    echo "Checking git command exists..."

    if [[ `which git` ]]; then
        logOkMessage "Git found!"
    else
        logError "Git not found :("
    fi
}

verifyDockerCLI() {
    logMessage "Verifying Docker CLI"
    echo "Checking docker command exists..."

    if [[ `which docker` ]]; then
        logOkMessage "Docker found!"
    else
        logError "Docker CLI not found :( you need to check manually."
    fi
}

verifyDockerCompose() {
    logMessage "Verifying Docker Compose"
    echo "Checking docker-compose command exists..."

    if [[ `which docker-compose` ]]; then
        logOkMessage "Docker Compose found!"
    else
        logError "Docker Compose not found :( you need to check manually."
    fi
}

verifyColima() {
    logMessage "Verifying Colima"
    echo "Checking colima command exists..."

    if [[ `which colima` ]]; then
        logOkMessage "Colima found!"
    else
        logError "Colima not found :( you need to check manually."
    fi
}

verifyYarn() {
    logMessage "Verifying Yarn"
    echo "Checking yarn command exists..."

    if [[ `which yarn` ]]; then
        logOkMessage "Yarn found!"
    else
        logError "Yarn not found :("
    fi
}

logMessage "TWU Setup Script"

case $1 in
    "")
    
    logMessage "Complete!"
    logOkMessage "Setup script complete"
    ;;

    "-dev")
    installHomebrew && installGit && installJava && installNode && installDockerCLIandCompose && installColima
    verifyJavaVersion && verifyNodeVersion && verifyGit && verifyDockerCLI && verifyDockerCompose && verifyColima

    if $wereErrors == true; then
      logError "Looks like we encountered a problem :( \n\nPlease reach out to your friendly super trainers for support and include a screenshot of your terminal output when you do :D"
    else
        logMessage "Complete!"
        logOkMessage "All TWU dependencies installed!\n\nPlease restart your terminal to finish setup."
    fi
    ;;

    "-sse")
    installHomebrew && installGit && installJava && installNode && installDockerCLIandCompose && installColima && installYarn && installRancher
    verifyJavaVersion && verifyNodeVersion && verifyGit && verifyDockerCLI && verifyDockerCompose && verifyColima && verifyYarn

    if $wereErrors == true; then
      logError "Looks like we encountered a problem :( \n\nPlease reach out to your friendly super trainers for support and include a screenshot of your terminal output when you do :D"
    else
        logMessage "Complete!"
        logOkMessage "All TWU dependencies installed!\n\nPlease restart your terminal to finish setup."
    fi
    ;;

    "-offboard")
    logMessage "Complete!"
    logOkMessage "Offboarding script complete"
    ;;

    *)
    logError "Unknown option '$1'"
    ;;
esac
