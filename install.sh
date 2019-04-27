#!/bin/bash -eu

trap 'clean' 0

clean() {
    echo ""
    echo "CLEANING..."
    sudo -k
}

main() {

    if [[ $(id -u) -eq 0 ]]; then
        echo "DON'T RUN ME AS ROOT"
        exit 1
    fi

    sudoRuns

    mkdir -p "$HOME/.config"

    otherStuff

    echo ""
    echo "Remember to install TMUX plugins by running CTRL+A CTRL SHIFT+I"
    echo "Remember to configure sublimetext after running it."
}

sudoRuns() {
    sudo -v -p "NEED ACCESS: "
    sudo apt-get update && sudo apt-get upgrade -y

    sudo update-alternatives --set editor /usr/bin/vim.basic

    prepareChrome
    prepareSublime

    sudo add-apt-repository -y ppa:git-core/ppa

    sudo apt-get update && sudo apt-get --with-new-pkgs upgrade -y

    installApps

    pushd cron
    sudo ./add-cron-jobs.sh
    popd

    pushd linux
    sudo ./add-keyboard-config.sh
    popd

    sudo -k
}

prepareChrome() {
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub \
        | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' \
        | sudo tee /etc/apt/sources.list.d/google-chrome.list
}

prepareSublime() {
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
        | sudo apt-key add -

    # echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    echo "deb https://download.sublimetext.com/ apt/dev/" \
        | sudo tee /etc/apt/sources.list.d/sublime-text.list
}

installApps() {
    sudo apt-get install -y $(awk '{print $1}' apps)
}

otherStuff() {
    runIn "bash" "add-bash-configs.sh"
    runIn "conky" "add-conky-config.sh"
    installTpm
    runIn "tmux" "add-tmux-conf.sh"
    runIn "urxvt" "enable-urxvt-configs.sh"
    runIn "vim" "add-vim-config.sh"
    runIn "xmonad" "add-xmonad.sh"
    runIn "firefox" "add-firefox-userjs.sh"
}

installTpm() {
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        pushd "$HOME/.tmux/plugins/tpm"
    git pull
    popd
    else
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
}

runIn() {
    pushd $1
    ./$2
    popd
}

popd() {
    command popd > /dev/null
}

main $@
