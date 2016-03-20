#!/bin/bash

echo '################';
echo '# Git Deployer';
echo '# v 0.1.1';
echo '# By @Darklg';
echo '################';
echo '';

###################################
## Change config values here
###################################

# - Project name
PROJID='myprojectname';

# - Public subfolder ( usually www )
PRODDIR='wwwfoldername';

###################################
## Install
###################################

# Vars
MAINPATH="$(pwd)/";
GITPATH="${MAINPATH}${PROJID}.git/";
SRCPATH="${MAINPATH}src/";
PRODPATH="${MAINPATH}${PRODDIR}/";
EXCLUDEFILENAME="exclude-list.txt";
EXCLUDEFILEPATH="${MAINPATH}${EXCLUDEFILENAME}";

# Install git repository if not available
cd "${MAINPATH}";
if [[ ! -d "${GITPATH}" ]]; then
    mkdir "${GITPATH}";
    cd "${GITPATH}";
    git init --bare;
    echo "- [${PROJID}] GIT Repository is initialized";
fi;

# Install src dir if not available
cd "${MAINPATH}";
if [[ ! -d "${SRCPATH}" ]]; then
    git clone "${GITPATH}" src;
    echo "- [${PROJID}] Prod is initialized";
fi;

# Install exclude file
cd "${MAINPATH}";
if [[ ! -f "${EXCLUDEFILEPATH}" ]]; then
    touch "${EXCLUDEFILEPATH}";
    echo ".git" >> "${EXCLUDEFILEPATH}";
    echo ".gitignore" >> "${EXCLUDEFILEPATH}";
    echo ".gitmodules" >> "${EXCLUDEFILEPATH}";
    echo "- [${PROJID}] Exclude file is initialized";
fi;

# Pull latest version
cd "${SRCPATH}";
git pull;
git submodule init;
git submodule update;
git pull;
echo "- [${PROJID}] Latest project files are pushed";

# Rsync to prod director
cd "${MAINPATH}";
rsync -ruv --exclude-from "${EXCLUDEFILENAME}" "${SRCPATH}" "${PRODPATH}";
echo "- [${PROJID}] Project is synchronized !";

# Scripts post deployment
if [[ ! -f "${MAINPATH}post-deploy.sh" ]]; then
    . "${MAINPATH}post-deploy.sh";
fi;
