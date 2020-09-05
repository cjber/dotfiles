FROM archlinux

RUN useradd -m cjber

# Allow notroot to run stuff as root (to install dependencies):
RUN echo "cjber ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cjber


RUN pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Sy --noconfirm base-devel git go  && \
    pacman -Syu --noconfirm && \
    pacman -S neovim python python-poetry python-pipenv python-neovim \
    nodejs npm fish --noconfirm

USER cjber
WORKDIR /home/cjber

RUN git clone https://github.com/cjber/dotfiles && \
        cd dotfiles && \


WORKDIR /root

COPY /config/nvim .config/nvim

RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

RUN nvim +PlugInstall +qall
