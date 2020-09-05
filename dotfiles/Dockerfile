FROM archlinux

# Generally, refreshing without sync'ing is discouraged, but we've a clean
# environment here.
RUN pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Sy --noconfirm base-devel git go  && \
    pacman -Syu --noconfirm && \
    pacman -S neovim python python-poetry python-pipenv python-neovim --noconfirm


RUN pyenv install 3.8.5 && \
        pyenv virtualenv 3.8.5 pyds 

WORKDIR /root

COPY /config/nvim .config/nvim

RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

RUN nvim +PlugInstall +qall
