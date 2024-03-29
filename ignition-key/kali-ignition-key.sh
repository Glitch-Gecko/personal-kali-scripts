#!/bin/bash

# Credit to John Hammond for base script and colors
# Define colors...
RED=`tput bold && tput setaf 1`
GREEN=`tput bold && tput setaf 2`
YELLOW=`tput bold && tput setaf 3`
BLUE=`tput bold && tput setaf 4`
NC=`tput sgr0`
user=$(who | awk 'NR==1{print $1}')
cd "${0%/*}"

function RED(){
	echo -e "\n${RED}${1}${NC}"
}
function GREEN(){
	echo -e "\n${GREEN}${1}${NC}"
}
function YELLOW(){
	echo -e "\n${YELLOW}${1}${NC}"
}
function BLUE(){
	echo -e "\n${BLUE}${1}${NC}"
}

# Testing if root...
if [ $EUID -ne 0 ]
then
	RED "[!] You must run this script as root!" && echo
	exit
fi

distro=$(uname -a | grep -i -c "kali") # distro check
if [ $distro -ne 1 ]
then 
	RED "[!] Kali Linux Not Detected - This script will not work with anything other than Kali!" && echo
	exit
fi

BLUE "Updating repositories..."
sudo apt update
sudo apt install -y git

BLUE "[*] Pimping my kali..."
git clone https://github.com/An00bRektn/pimpmykali /home/$user/pimpmykali
cd /home/$user/pimpmykali
sudo ./pimpmykali.sh --all
cd -

BLUE "[*] Installing NVIM and packer.nvim"
# NVIM
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage /bin/nvim

# packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

BLUE "[*] Installing Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

BLUE "[*] Installing virtualenv..."
sudo apt install -y virtualenv

BLUE "[*] Installing pipx..."
sudo apt install -y pipx

BLUE "[*] Installing pyftpdlib..."
sudo -u $user pip3 install -U pyftpdlib

BLUE "[*] Installing xclip..."
sudo apt install -y xclip

BLUE "[*] Installing mingw-w64..."
sudo apt install -y mingw-w64

BLUE "[*] Installing tmux (and terminator as a fallback)..."
sudo apt install -y tmux terminator

BLUE "[*] Installing alacritty..."
wget https://github.com/barnumbirr/alacritty-debian/releases/download/v0.11.0-1/alacritty_0.11.0-1_amd64_bullseye.deb
sudo dpkg -i alacritty_0.11.0-1_amd64_bullseye.deb
sudo apt install -f

BLUE "[*] Getting enum4linux-ng..."
git clone https://github.com/cddmp/enum4linux-ng.git /opt/enum4linux-ng

BLUE "[*] Installing rustscan..."
wget https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb && sudo dpkg -i rustscan_2.0.1_amd64.deb && sudo rm -f rustscan_2.0.1_amd64.deb

BLUE "[*] Installing ffuf..."
sudo apt install -y ffuf

BLUE "[*] Installing feroxbuster..."
sudo apt install -y feroxbuster

BLUE "[*] Installing Bloodhound..."
sudo apt install -y bloodhound
sudo apt install -y neo4j

BLUE "[*] Installing seclists..."
sudo apt install -y seclists

BLUE "[*] Installing gdb..."
sudo apt install -y gdb

BLUE "[*] Installing pwndbg..."
git clone https://github.com/pwndbg/pwndbg /opt/pwndbg
chown -R $user /opt/pwndbg
cd /opt/pwndbg
./setup.sh
cd -

BLUE "[*] Installing ghidra..."
sudo apt install -y ghidra

BLUE "Installing pdfcrack..."
sudo apt install -y pdfcrack

BLUE "Installing sshpass..."
sudo apt install -y sshpass

BLUE "Installing GIMP..."
sudo apt install -y gimp

BLUE "[*] Installing AutoRecon..."
git clone https://github.com/Tib3rius/AutoRecon.git /opt/AutoRecon
cd /opt/AutoRecon
virtualenv env -p $(which python3)
source env/bin/activate
pip install -r requirements.txt
deactivate
cd -

BLUE "[*] Installing pwntools and other binary exploitation tools..."
sudo -u $user pip3 install -U pwntools ropper
sudo gem install one_gadget seccomp-tools

BLUE "[*] Installing codium..."
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update
sudo apt install codium -y

BLUE "[*] Installing guessing tools..."
sudo apt install -y steghide
sudo gem install zsteg
sudo -u $user pip3 install -U stegoveritas
/home/$user/.local/bin/stegoveritas_install_deps

BLUE "[*] Installing some lighter forensics tools..."
sudo -u $user pip3 install -U oletools
sudo -u $user pip3 install -U pyshark
sudo apt install -y strace ltrace
wget https://didierstevens.com/files/software/DidierStevensSuite.zip -O /opt/DidierStevensSuite.zip
chown $user /opt/DidierStevensSuite.zip

BLUE "[*] Installing sliver..."
curl https://sliver.sh/install | sudo bash

BLUE "[*] Installing Nim..."
sudo -u $user curl https://nim-lang.org/choosenim/init.sh -sSf | sh
echo 'export PATH=/home/$user/.nimble/bin:$PATH' >> /home/$user/.zshrc


BLUE "[*] Installing various cryptography tools..."
sudo apt install libgmp-dev libmpc-dev libmpfr-dev -y
sudo -u $user pip3 install PyCryptodome gmpy2 pwntools

BLUE "[*] Installing docker..."
sudo apt install -y docker.io
sudo systemctl enable docker --now
sudo usermod -aG docker $user

BLUE "[*] Installing various cryptography tools pt 2..."
sudo docker pull hyperreality/cryptohack:latest

# Comment out any of the following dotfiles to keep current files
function dotfiles(){
    git clone https://github.com/Glitch-Gecko/configs.git
    cd configs/dotfiles

    # Bash dotfiles
    cp ./kali/.bash_aliases-kali /home/$user/.bash_aliases
    cp ./kali/.bashrc-kali /home/$user/.bashrc
    chown $user /home/$user/.bashrc /home/$user/.bash_aliases
    echo 'export PATH=/home/$user/.nimble/bin:$PATH' >> /home/$user/.bashrc
    source /home/$user/.bash_aliases
    source /home/$user/.bashrc
    
    # Tmux dotfiles
    cp ./tmux/.tmux.conf /home/$user/.tmux.conf
    mkdir /home/$user/.tmux
    cp ./tmux/left_status.sh /home/$user/.tmux/left_status.sh
    cp ./tmux/right_status.sh /home/$user/.tmux/right_status.sh
    cp ./tmux/tmux_setup.sh /home/$user/.tmux/tmux_setup.sh
    cp ./tmux/tmux.desktop /home/$user/.config/autostart/tmux.desktop
    sed -i "3 i\Exec=qterminal -e /home/$user/.tmux/tmux_setup.sh" /home/$user/.config/autostart/tmux.desktop
    chmod +x /home/$user/.tmux/left_status.sh
    chmod +x /home/$user/.tmux/right_status.sh
    chmod +x /home/$user/.tmux/tmux_setup.sh

    # Alacritty dotfiles
    cp ./alacritty /home/$user/.config -r
	
	# Changing background
	mv /usr/share/backgrounds/kali-16x9/default /usr/share/backgrounds/kali-16x9/default.original
	cp ./wallpapers/kali-lincox.png /usr/share/backgrounds/kali-16x9/default

	# NVIM dotfiles
	cp ./nvim /home/$user/.config -r

	# ZSH dotfiles
	rm /home/$user/.zshrc
	cp ./kali/.zshrc /home/$user

    cd ../..
    rm -rf configs
}

dotfiles

GREEN "[++] All done! Happy hacking! Rebooting in 5 seconds and deleting files!"
sleep 5
rm ../../personal-kali-scripts -rf
reboot
