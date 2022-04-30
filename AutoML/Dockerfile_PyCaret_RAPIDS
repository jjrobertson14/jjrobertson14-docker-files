FROM ubuntu:20.04

# Init
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y

# Set timezone
ENV TZ=America/New_York
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Run command as rhythm user to get powerline-go
RUN cd /home/rhythm && sudo -u rhythm go get -u github.com/justjanne/powerline-go && sudo -u rhythm ln -s [run dir path] .

# add files to run directory
# COPY ./home_rhythm.tar.bz2 /home/rhythm
# RUN [script name - initialize-python-environment for notebook to run in].sh

# At this point should be able to access notebook from VS Code...
