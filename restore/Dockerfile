FROM archlinux
RUN useradd -m cjber

RUN pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Sy --noconfirm base-devel git go  && \
    pacman -Syu --noconfirm && \
    pacman -S python python-poetry python-pipenv python-neovim \
    nodejs npm fish ranger pyenv --noconfirm

WORKDIR /root

RUN git clone https://github.com/cjber/dotfiles && \
        mkdir .config/ && \
        cp -r dotfiles/dotfiles/config/nvim .config/nvim
RUN mkdir .config/nvim/plug
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'


# Allow notroot to run stuff as root (to install dependencies):
RUN echo "cjber ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cjber
USER cjber
WORKDIR /home/cjber
RUN git clone https://aur.archlinux.org/fisher.git && \
        cd fisher && \
        makepkg -si --noconfirm && \
        sudo pacman -U fisher*.pkg.* --noconfirm && \
        cd && \
        git clone https://aur.archlinux.org/pyenv-virtualenv.git && \
        cd pyenv-virtualenv && \
        makepkg -si --noconfirm && \
        sudo pacman -U pyenv-virtualenv*.pkg.* --noconfirm && \
        cd && \
        git clone https://aur.archlinux.org/neovim-git.git && \
        cd neovim-git && \
        makepkg -si --noconfirm && \
        sudo pacman -U neovim*.pkg.* --noconfirm

RUN nvim +PlugInstall +qall
USER root
WORKDIR /root

# --yes doesn't seem to work when piping to bash
RUN curl -fsSl https://raw.githubusercontent.com/starship/starship/master/install/install.sh -o starship.sh && chmod +x starship.sh
RUN ./starship.sh --yes

COPY /config/ranger .config/ranger
COPY /config/fish .config/fish
COPY /config/starship.toml .config/starship.toml
COPY /run/entrypoint.sh /run/entrypoint.sh
RUN pip install neovim \
        wheel \
        python-language-server[all] \
        autopep8 \
        pylint \
        sourcery-cli \
        seaborn \
        matplotlib \
        pandas \
        numpy \
        statsmodels \
        allennlp \
        allennlp-models
RUN echo 'let g:python3_host_prog = "/sbin/python"' >> /root/.config/nvim/init.vim

RUN chmod +x /run/entrypoint.sh
ENTRYPOINT ["/run/entrypoint.sh"]
