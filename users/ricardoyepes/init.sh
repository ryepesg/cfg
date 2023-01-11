# This file is meant to be run only once after the initial machine setup
# Not making it executable or adding shebang to avoid running it by mistake
# Execute it as: sh .init.sh

if [ -d "${HOME}/data-vault" ] || [ -L "${HOME}/data-vault" ]; then
    echo "The initial setup completed already"
else
    cd ~
    git clone git@github.com:ryepesg/data-vault.git
    source $HOME/.os.sh
fi
