FROM phusion/baseimage:0.9.17
MAINTAINER Chris Snow

ENV HOME /root

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y language-pack-en
ENV LANG en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN (mv /etc/localtime /etc/localtime.org && \
     ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime)

RUN (apt-get update && \
     DEBIAN_FRONTEND=noninteractive \
     apt-get install -y build-essential software-properties-common \
                        zlib1g-dev libssl-dev libreadline-dev libyaml-dev \
                        libxml2-dev libxslt-dev sqlite3 libsqlite3-dev \
                        vim git byobu wget curl unzip tree exuberant-ctags \
                        build-essential cmake python python-dev gdb)

# Add a non-root user
RUN (useradd -m -d /home/docker -s /bin/bash docker && \
     echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers)

# Install eclim requirements
RUN (apt-get install -y openjdk-7-jdk ant maven \
                        xvfb xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic)

USER docker
ENV HOME /home/docker
WORKDIR /home/docker

#    git clone --recursive https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe && \

# Checkout my vimrc
RUN (git clone git://github.com/snowch/vimrc.git ~/.vim && \
    mkdir ~/.vim/plugin && \
    ln -s ~/.vim/.vimrc ~/.vimrc && \
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim && \
    mkdir ~/.vim/colors && \
    curl -s https://raw.githubusercontent.com/endel/vim-github-colorscheme/master/colors/github.vim > ~/.vim/colors/github.vim && \
    curl -s http://www.vim.org/scripts/download_script.php?src_id=20938 > ~/.vim/plugin/colorsupport.vim && \
    ln -s ~/.vim/.tmux.conf ~/.tmux.conf)

# Force tmux to use 256 colors to play nicely with vim
RUN echo 'alias tmux="tmux -2"' >> ~/.profile

RUN vim -N +PluginInstall +qall 

RUN cd ~/.vim/bundle/YouCompleteMe; ./install.py --clang-completer


# Install Eclipse and eclim
RUN (wget -O /home/docker/eclipse-java-mars-R-linux-gtk-x86_64.tar.gz \
             "http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/mars/R/eclipse-java-mars-R-linux-gtk-x86_64.tar.gz&r=1" && \
     tar xzvf eclipse-java-mars-R-linux-gtk-x86_64.tar.gz -C /home/docker && \
     rm eclipse-java-mars-R-linux-gtk-x86_64.tar.gz && \
     mkdir /home/docker/workspace && \
     cd /home/docker && git clone git://github.com/ervandew/eclim.git && \
     cd eclim && ant -Declipse.home=/home/docker/eclipse)

USER root
ADD service /etc/service
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
