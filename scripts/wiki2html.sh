# ~/.dotfiles/wiki2html.sh

env HUGO_baseURL="file:///home/${USER}/drive/wiki/_site/" \
    hugo \
    --config ~/drive/hugo/config.toml \
    --contentDir ~/drive/wiki/ \
    -d ~/drive/wiki/_site --quiet > /dev/null
