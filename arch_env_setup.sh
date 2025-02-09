sudo pacman -S git base-devel

echo "Installing yay package manager"
mkdir $HOME/Utils
git clone https://aur.archlinux.org/yay.git $HOME/Utils/yay
cd $HOME/Utils/yay
sudo makepkg -si

cd -

echo "Begin of programming languages installation"
echo "Installing latest OpenJDK"
sudo pacman -S jdk-openjdk --noconfirm

echo "Installing python, virtualenv and pip"
sudo pacman -S python python-virtualenv python-pip --noconfirm

echo "Installing lua"
sudo pacman -S lua --noconfirm

echo "Installing nodejs"
sudo pacman -S nodejs --noconfirm
echo "End of programming languages installation"


echo "Begin of programming utils installation"
echo "Installing ripgrep, fd, fzf, tmux and tree-sitter"
echo "Don't forget to clone your tmux config"
sudo pacman -S ripgrep fd fzf tmux tree-sitter tree-sitter-cli --noconfirm

echo "Setting up fzf global envs (see $HOME/.bashrc)"
echo "export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs'" > $HOME/.bashrc
echo "export FZF_CTRL_T_COMMAND='$FZF_DEFAULT_COMMAND'" > $HOME/.bashrc
echo "export FZF_ALT_C_COMMAND='fd --type d --follow --strip-cwd-prefix'" > $HOME/.bashrc


echo "Installing ghostty"
sudo pacman -S ghostty --noconfirm

echo "Installing nvim"
sudo pacman -S neovim --noconfirm
echo "Don't forget to clone your nvim config"

echo "Installing podman"
sudo pacman -S podman --noconfirm
echo "End of programming utils installation"
