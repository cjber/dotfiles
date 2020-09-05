FROM archlinux
RUN useradd -m cjber

RUN pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Sy --noconfirm base-devel git go  && \
    pacman -Syu --noconfirm && \
    pacman -S neovim python python-poetry python-pipenv python-neovim \
    nodejs npm fish ranger pyenv --noconfirm

WORKDIR /root

RUN git clone https://github.com/cjber/dotfiles && \
        cd dotfiles/restore

COPY /config/nvim .config/nvim
RUN mkdir .config/nvim/plug

RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

RUN nvim +PlugInstall +qall

# Allow notroot to run stuff as root (to install dependencies):
RUN echo "cjber ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cjber
USER cjber
WORKDIR /home/cjber
RUN git clone https://aur.archlinux.org/fisher.git && \
        cd fisher && \
        makepkg -si --noconfirm && \
        sudo pacman -U fisher*.pkg.* --noconfirm

USER root
WORKDIR /root

# --yes doesn't seem to work when piping to bash
RUN curl -fsSl https://raw.githubusercontent.com/starship/starship/master/install/install.sh -o starship.sh && chmod +x starship.sh
RUN ./starship.sh --yes

COPY /config/ranger .config/ranger
COPY /config/fish .config/fish
COPY /config/starship.toml .config/starship.toml
