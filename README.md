# docker-vim--eclim

Enterprise Java development in Vim running in a Docker container

This container is powered by the following open source software
products:

- **Vim 7.4**
- **Eclipse Mars** with **OpenJDK 7**
- **[eclim](http://eclim.org/)** -- eclim brings Eclipse functionality
  to the Vim editor

[`phusion/baseimage`](https://hub.docker.com/r/phusion/baseimage/) is
used as the base image, which is built upon Ubuntu 14.04 LTS.


## Build the Docker Image


```
$ docker build -t vim-eclim .
```

## Running the Docker Container

After building, you can just pull the image and run it.

```
$ docker run -it --name=vim-eclim \
             vim-eclim:latest \
             /sbin/my_init -- su - docker
```

This will start xvfb service in order to create a fake display for
Eclipse, and then drop you in a shell with `docker` user.


### Start Eclipse via eclimd

Inside the container, start Eclipse via eclimd.

```
$ tmux
$ DISPLAY=:1 ./eclipse/eclimd
```

You should wait for the following message before connecting from
Emacs.

```
INFO  [org.eclim.eclipse.EclimDaemon] Eclim Server Started on: 127.0.0.1:9091
```

Alternatively, you can start eclimd with background option.

```
$ DISPLAY=:1 ./eclipse/eclimd -b
```


### Start Vim

Press `C-b c` to create a new tmux screen. Then start Vim.

```
$ vim
```

TODO - add first eclim step

## Persisting Your Projects with Docker Volumes

Since this is a Docker environment, you will lose all changes in your
container when you kill it (unless you do `docker commit`).

You can use Docker volumes with bind mount to map the host
directories/files to the container.

For example,

```
$ docker run -it --name=emacs-eclim \
             -v /path/to/myproject:/home/docker/workspace/myproject \
             vim-eclim:latest \
             /sbin/my_init -- su - docker
```

Then change the owner of the project folder and files in the container

```
$ sudo chown -R docker:docker ~/workspace/myproject
```

My Java projects are mirrored in remote git repositories via ssh
access and some of them uses Maven or Ivy. So I usually start the
container with something like the following:

```
$ docker run -it --name=vim-eclim \
             -v /path/to/myproject:/home/docker/workspace/myproject \
             -v /path/to/ssh:/home/docker/.ssh \
             -v /path/to/gitconfig:/home/docker/.gitconfig \
             -v /path/to/m2:/home/docker/.m2 \
             -v /path/to/ivy2:/home/docker/.ivy2 \
             vim-eclim:latest \
             /sbin/my_init -- su - docker
```

For further details about Docker volumes, see the
[Docker Cheat-Sheet](https://github.com/wsargent/docker-cheat-sheet#volumes)


## Special Thanks!

This Docker images was inspired by the following project:

- https://github.com/tatsuya6502/docker-emacs-eclim
