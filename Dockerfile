FROM ubuntu:rolling
LABEL maintainer="dev@jasoncarloscox.com"

# install dependencies
RUN sed -i 's/apt-get upgrade/apt-get upgrade -y/' /usr/local/sbin/unminimize && \
    sed -i 's/^read .*$/REPLY=y/' /usr/local/sbin/unminimize && \
    unminimize && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bash-completion \
        fzf \
        git \
        locales \
        man-db \
        nodejs \
        openssh-client \
        ripgrep \
        sudo \
        tmux \
        vim && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/fzf && \
    ln -s /usr/share/doc/fzf/examples/key-bindings.bash /usr/share/fzf/key-bindings.bash && \
    ln -s /usr/share/doc/fzf/examples/completion.bash /usr/share/fzf/completion.bash && \
    ln -s /usr/share/doc/fzf/examples/fzf.vim /usr/share/vim/vim81/plugin/fzf.vim

# setup locale
RUN sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo LANG=en_US.UTF-8 > /etc/locale.conf

# setup user
ARG user=jason
ARG password=$user
ARG group=jason
ARG uid=1000
ARG gid=1000

RUN groupadd --gid $gid $group && \
    useradd \
        --create-home \
        --gid $gid \
        --groups sudo \
        --home-dir /home/$user \
        --password $(perl -e 'print crypt($ARGV[0], "password")' $password) \
        --shell /bin/bash \
        --uid $uid \
        $user && \

    # fix annoying sudo output (https://github.com/sudo-project/sudo/issues/42)
    echo "Set disable_coredump false" >> /etc/sudo.conf

USER $user:$group
WORKDIR /home/jason
ENV USER $user

# set needed environment variables
ENV LANG=en_US.UTF-8 \
    TERM=xterm-256color \
    USER=$user

# download generic configurations
RUN git clone --recurse-submodules https://github.com/jasonccox/dotfiles.git && \
    mkdir -p ~/.config/coc && \
    cd dotfiles && \
    ./setup.sh git shell ssh tmux vim && \
    rm -rf .git karabiner pim plasma setup.sh vimium-options.json

# add project- or language-specific configurations here
