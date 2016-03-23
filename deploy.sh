#!/bin/bash

echo '################';
echo '# Git Deployer';
echo '# v 0.2.1';
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

# - 1-step deploy ('y' to activate)
ONESTEPDEPLOY='n';

###################################
## Install
###################################

# Vars
MAINPATH="$(pwd)/";
GITPATH="${MAINPATH}${PROJID}.git/";
HOOKPATH="${GITPATH}hooks/post-receive";
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
    if [[ "${ONESTEPDEPLOY}" == 'y' ]]; then
        touch "${HOOKPATH}";
        chmod +x "${HOOKPATH}";
        echo "#!/bin/sh" >> "${HOOKPATH}";
        echo "cd ${MAINPATH}" >> "${HOOKPATH}";
        echo ". deploy.sh" >> "${HOOKPATH}";
    fi;
fi;

# Install src dir if not available
cd "${MAINPATH}";
if [[ ! -d "${SRCPATH}" ]]; then
    git clone "${GITPATH}" src;
    echo "- [${PROJID}] Source folder is initialized";
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
echo "- [${PROJID}] Latest project files are pulled";

# Rsync to prod director
cd "${MAINPATH}";
rsync -ruv --exclude-from "${EXCLUDEFILENAME}" "${SRCPATH}" "${PRODPATH}";
echo "- [${PROJID}] Project is synchronized !";

# Scripts post deployment
if [[ -f "${MAINPATH}post-deploy.sh" ]]; then
    . "${MAINPATH}post-deploy.sh";
fi;
