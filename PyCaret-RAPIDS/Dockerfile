# Build with this to use the host network for downloads docker build --network=host --tag=pycaret-rapids:latest .
# Run with Volume with `docker run --rm --gpus all --network=host --mount type=bind,src="$(pwd)/data",target=/opt/workdir/data pycaret-rapids:latest`

FROM ubuntu:20.04 as build
USER root

# On ARG and ENV, in case you want to add:
#   You can use ENV instructions in a Dockerfile to define variable values. These values persist in the built image. 
#   However, often persistence is not what you want. Users want to specify variables differently depending on which host they build an image on.
#   The ARG instruction lets Dockerfile authors define values that users can set at build-time using the --build-arg flag:
#       docker build --build-arg HTTP_PROXY=http://10.20.30.2:1234 --build-arg FTP_PROXY=http://40.50.60.5:4567 .
#   This flag allows you to pass the build-time variables that are accessed like regular environment variables in the RUN instruction of the Dockerfile. Also, these values don’t persist in the intermediate or final images like ENV values do. You must add --build-arg for each build argument.

# Set Environment Variables
ENV TZ=America/New_York

# Set workdir
ENV BASEDIR=/opt/workdir
RUN mkdir -p $BASEDIR
WORKDIR $BASEDIR

# Create output directory
RUN mkdir $BASEDIR/outputLocal

# Update and Install dependencies with apt-get
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y &&\
    apt-get install -y build-essential \
                       cmake \
                       curl \
                       gfortran \
                       git \
                       jupyter \
                       libatlas-base-dev \
                       libblas-dev \
                       libbz2-dev \
                       libffi-dev \
                       libgdbm-dev \
                       liblapack-dev \
                       liblzma-dev \
                       libncurses5-dev \
                       libncursesw5-dev \
                       libreadline-dev \
                       libsqlite3-dev \
                       libssl-dev \
                       libxml2-dev \
                       libxmlsec1-dev \
                       llvm \
                       lzma \
                       lzma-dev \
                       make \
                       pip \
                       tcl-dev \
                       tk-dev \
                       wget \
                       xz-utils \
                       zlib1g-dev

# TODO try using alpine base image at the top, get build to work, get run to work
#   FROM alpine:3.14
# TODO for Alpine, use this install list instead
# TODO (try using something other than pyenv to resolve error on swapping Ubuntu for Alpine Linux...) 
#      (resolve error "C compiler cannot create executables" on running pyenv install 3.7.13)
# Worked with alpine Linux base image...
# RUN apk update && apk upgrade &&\
#     apk add bash \
#             cmake \
#             curl \
#             gcc \
#             gfortran \
#             git \
#             libffi-dev \
#             libxml2-dev \
#             llvm \
#             make \
#             patch \
#             tcl-dev \
#             tk-dev \
#             wget

# (NOTE: Use guide here to install pyenv https://github.com/pyenv/pyenv#installation)
# (Install python, python 3.7 is good for ML 2022/05/03)
# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv &&\
    # Edit .bashrc
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc &&\
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc &&\
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc &&\
    echo 'export PATH=$PATH:/home/johna/.pyenv/versions/3.7.13/bin' >> ~/.bashrc &&\
    # Edit .bash_profile
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile &&\
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile &&\
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile &&\
    echo 'export PATH=$PATH:/home/johna/.pyenv/versions/3.7.13/bin' >> ~/.bash_profile &&\
    # Source bash_profile
    . ~/.bash_profile &&\
    # install python 3.7.13 with pyenv
    pyenv install 3.7.13 &&\
    pyenv global 3.7.13

# Create a virtualenv to install as a python kernel for Jupyter Notebook to use
RUN . ~/.bash_profile && python -m venv .

# Activate the virtualenv then...
# Upgrade pip and install packages with it
RUN . ./bin/activate &&\
    cat ~/.bash_profile && . ~/.bash_profile && pyenv versions && which python && which pip &&\
    python -m pip install --upgrade pip &&\
    python -m pip install Cython \
                          ez_setup \
                          mlflow \
                          numpy \
                          pybind11 \
                          ruamel.yaml \
                          scipy \
                          setuptools \
                          wheel \
                          # Install SciKit Learn and SciPy packages with pip
                          scikit-learn \
                          sklearn-pandas \
                          scikit-plot \
                          scipy \
                          # Install PyCaret with pip
                          pycaret \
                          # Install jupyter in the virtualenv
                          ipykernel \
                          jupyter &&\
    python -m pip freeze > requirements.txt &&\
    echo Path is $PATH
    # Add the virtualenv as a jupyter kernel

# help for Kernel install... https://ipython.readthedocs.io/en/stable/install/kernel_install.html
RUN . ~/.bash_profile && python -m ipykernel install --user
RUN . ~/.bash_profile && jupyter kernelspec install . --user --name="python-3.7.13"
    
# NOTE: I have previously seen pip install errors:
    # Go here for all the help you should need for handling Python dependency errors, it's short.
    #   (https://pip.pypa.io/en/stable/topics/dependency-resolution/#dealing-with-dependency-conflicts)
    # There are no catch-all solutions except using Conda or Python Poetry.
    # 
    # (like "packageX version has requirement packageY>=version, but you'll have packageY version which is incompatible.)
    # 
    # (RUN 1:)
    # yellowbrick 1.4 has requirement scikit-learn>=1.0.0, but you'll have scikit-learn 0.23.2 which is incompatible.
    # numba 0.54.1 has requirement numpy<1.21,>=1.17, but you'll have numpy 1.22.3 which is incompatible.
    #
    # (RUN X:)
    # Fixed by moving package installations around and removing unneccessary installs (unused AzureML ones mainly). For the fussiest big packages, put install into one RUN command, and install the packages it whines aboute before the RUN command

# Done with RUN commands
FROM build

# Add project files
COPY PyCaretBenchmarkNotebook.ipynb .
#           Could take in python packages, required apt packages, and the notebook. Requires copy of files from first image into the second FROM <base image>
# Start notebook webserver at localhost with CMD command
ENTRYPOINT [ "jupyter", "notebook", "--ip='*'", "--port=8888", "--allow-root", "PyCaretBenchmarkNotebook.ipynb" ]

# At this point should be able to access notebook from VS Code...
# TODO optimize build more (I feel like significant amount of space could be saved considering image size is 3.35GB for me...)
