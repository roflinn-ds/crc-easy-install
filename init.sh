#!/bin/sh 

# Set to your PULL-SECRET file location and admin password.
SECRET_PATH="/Users/erics/bin/pull-secret"

# OpenShift client details
OC_MAJOR_VER="v4"
OC_MINOR_VER=2
OC_MINI_VER=0
OCP_VERSION="${OC_MAJOR_VER}.${OC_MINOR_VER}"
OC_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.2"

# Code Ready Containers details.
VIRT_DRIVER="hyperkit"
CRC_LINUX="https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/crc-linux-amd64.tar.xz"
CRC_OSX="https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/crc-macos-amd64.tar.xz"

# Config files.
ADMINPASS="${HOME}/.crc/cache/crc_hyperkit_4.2.0/kubeadmin-password"
KUBECONFIG="${HOME}/.crc/cache/crc_hyperkit_4.2.0/kubeconfig"

# wipe screen.
clear 

echo
echo "####################################################################"
echo "##                                                                ##"   
echo "##  Setting up OpenShift Container Plaform locally with:          ##"
echo "##                                                                ##"   
echo "##                                                                ##"   
echo "##    ####  ###  ####  #####     ##### #####  ###  ####  #   #    ##"
echo "##   #     #   # #   # #         #   # #     #   # #   # #   #    ##"
echo "##   #     #   # #   # ###       ##### ###   ##### #   #  ###     ##"
echo "##   #     #   # #   # #         #  #  #     #   # #   #   #      ##"
echo "##    ####  ###  ####  #####     #   # ##### #   # ####    #      ##"
echo "##                                                                ##"   
echo "##                                                                ##"   
echo "##    ####  ###  #   # #####  ###  ##### #   # ##### ##### #####  ##"
echo "##   #     #   # ##  #   #   #   #   #   ##  # #     #   # #      ##"
echo "##   #     #   # # # #   #   #####   #   # # # ###   #####  ###   ##"
echo "##   #     #   # #  ##   #   #   #   #   #  ## #     #  #      #  ##"
echo "##    ####  ###  #   #   #   #   # ##### #   # ##### #   # #####  ##"
echo "##                                                                ##"   
echo "##                                                                ##"   
echo "##  https://gitlab.com/redhatdemocentral/ocp-install-demo         ##"
echo "##                                                                ##"   
echo "####################################################################"
echo

# Check virtualization.
#
if [ `uname` == 'Darwin' ]; then
		command hyperkit -v >/dev/null 2>&1 || { echo >&2 "Hyperkit is required but not installed yet... install using brew."; exit 1; }
		VIRT_DRIVER='hyperkit'
		echo "HyperKit is installed..."
		echo
elif [ `uname` == 'Linux' ]; then
		VIRT_DRIVER='libirt'
    echo "You are running on Linux. This script assumes you have libvirt running on your Linux."
		echo
fi

# Ensure OpenShift command line tools available.
#
command -v oc version --client >/dev/null 2>&1 || { echo >&2 "OpenShift CLI tooling is required but not installed yet... download ${OCP_VERSION} here (unzip and put on your path): ${OCP_URL}"; exit 1; }
echo "OpenShift command line tools installed... checking for valid version..."
echo

# Check oc version.
verfull=$(oc version --client | awk '{print $3}')
verone=$(echo ${verfull} | awk -F[=.] '{print $1}')
vertwo=$(echo ${verfull} | awk -F[=.] '{print $2}')
verthree=$(echo ${verfull} | awk -F[=.] '{print $3}')

# Check version elements, first is a string so using '==', the rest are integers.
if [ ${verone} == ${OC_MAJOR_VER} ] && [ ${vertwo} -eq ${OC_MINOR_VER} ] && [ ${verthree} -ge ${OC_MINI_VER} ]; then
	echo "Version of installed OpenShift command line tools correct... ${verone}.${vertwo}.${verthree}"
	echo
else
	echo "Version of installed OpenShift command line tools is ${verone}.${vertwo}.${verthree}, must be ${OC_MAJOR_VER}.${OC_MINOR_VER}.${OC_MINI_VER}..."
	echo
	if [ `uname` == 'Darwin' ]; then
		echo "Download Mac client here: ${OCP_URL}"
		echo
		exit
	else
		echo "Download Linux client here: ${OCP_URL}"
		echo
		exit
	fi
fi

# Check on Code Read Containers availability.
#
if [ `uname` == 'Darwin' ]; then
    command -v crc version >/dev/null 2>&1 || { echo >&2 "Code Ready Containers is not yet installed... download here (unzip and put on your path): ${CRC_OSX}"; exit 1; }
		echo "Code Ready Container is installed on your OSX machine..."
		echo
elif [ `uname` == 'Linux' ]; then
    command -v crc version >/dev/null 2>&1 || { echo >&2 "Code Ready Containers is not yet installed... download here (unzip and put on your path): ${CRC_LINUX}"; exit 1; }
		echo "Code Ready Container is installed on your Linux machine..."
		echo
fi

echo "Running Code Ready Containers setup on this machine, even if done before..."
echo
crc setup 

if [ $? -ne 0 ]; then
		echo
		echo "Error occurred during 'crc setup' command..."
		echo
		exit;
fi

echo
echo "Before starting, setting up pull secret file location..."
echo

if [ -z ${SECRET_PATH} ]; then
	# empty file variable.
	echo
	echo "################################################################################"
	echo "#                                                                              #"
	echo "#  Missing Pull Secret file for starting this Code Ready Containers platform,  #"
	echo "#  please download from:                                                       #"
	echo "#                                                                              #"
	echo "#     https://cloud.redhat.com/openshift/install/crc/installer-provisioned     #"
	echo "#                                                                              #"
	echo "#  Then update the variable 'SECRET_PATH' at top of this file to point to the  #"
	echo "#  downlaoded file. (i.e. SECRET_PATH='~/bin/pull-secret')                     #"
	echo "#                                                                              #"
	echo "################################################################################"
	echo
	echo
	exit
fi
	
# secret path set, so commit to configuration.
echo "Setting pull-secret-file in cofiguration to: ${SECRET_PATH}"
echo
crc config set pull-secret-file ${SECRET_PATH}

if [ $? -ne 0 ]; then
		echo
		echo "Error occurred during 'crc config set pull-secret-file' command..."
		echo
fi

echo
echo "Starting Code Ready Containers platform..."
echo
echo "This can take some time, so feel free to grab a coffee..."
echo
echo "#####################################################################"
echo "##                                                                 ##"   
echo "##   ####  ###  ##### ##### ##### #####   ##### ##### #   # #####  ##"
echo "##  #     #   # #     #     #     #         #     #   ## ## #      ##"
echo "##  #     #   # ####  ####  ###   ###       #     #   # # # ###    ##"
echo "##  #     #   # #     #     #     #         #     #   #   # #      ##"
echo "##   ####  ###  #     #     ##### #####     #   ##### #   # #####  ##"
echo "##                                                                 ##"   
echo "#####################################################################"
echo
echo
crc start

if [ $? -ne 0 ]; then
		echo
		echo "Error occurred during 'crc start' command..."
		echo
fi

# retrieve kubeadmin password.
echo
echo "Retrieving the admin password..."
echo
KUBE_PASS=$(cat ${ADMINPASS})

# retreive oc login host.
echo "Retrieving oc client host login from kubeconfig file..."
echo
OCP_HOST=$(cat ${KUBECONFIG} | grep server | awk -F'[:]' '{print $2":"$3":"$4}')

echo 
echo "Set OCP_HOST to:  $OCP_HOST"
echo

echo "Logging in as developer using oc client..."
echo
# log in to OCP cluster.
oc login ${OCP_HOST} -u developer -p developer

if [ $? -ne 0 ]; then
		echo
		echo "Error occurred during 'oc login' command..."
		echo
fi

# detect console url.
OCP_CONSOLE=$(crc console --url)

echo
echo "======================================================"
echo "=                                                    ="
echo "=  Install complete, get ready to rock.              ="
echo "=                                                    ="
echo "=  The server is accessible via web console at:      ="
echo "=                                                    ="
echo "= ${OCP_CONSOLE} ="
echo "=                                                    ="
echo "=  Log in as admin: kubeadmin                        ="
echo "=         password: ${KUBE_PASS}          ="
echo "=                                                    ="
echo "=  Log in as dev: developer                          ="
echo "=       password: developer                          ="
echo "=                                                    ="
echo "=  Now get your Red Hat Demo Central example         ="
echo "=  projects here:                                    ="
echo "=                                                    ="
echo "=     https://github.com/redhatdemocentral           ="
echo "=                                                    ="
echo "=  To stop, restart, or delete your OCP cluster:     ="
echo "=                                                    ="
echo "=     $ crc {stop | start | delete}                  ="
echo "=                                                    ="
echo "======================================================"
