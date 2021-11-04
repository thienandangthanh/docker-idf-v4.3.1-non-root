FROM espressif/idf:v4.3.1

RUN apt-get update && apt-get upgrade -y
RUN apt-get install udev -y

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

ENV LC_ALL=C.UTF-8

# QEMU for ESP32
# RUN apt-get update && apt-get install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev libgcrypt20-dev -y

# ARG QEMU_CLONE_URL=https://github.com/espressif/qemu
# ENV QEMU_PATH=/opt/qemu

# RUN git clone $QEMU_CLONE_URL $QEMU_PATH
# Configure & Build
# RUN cd $QEMU_PATH &&\
# ./configure --target-list=xtensa-softmmu \
# --enable-gcrypt \
# --enable-debug --enable-sanitizers \
# --disable-strip --disable-user \
# --disable-capstone --disable-vnc \
# --disable-sdl --disable-gtk &&\
# ninja -C build

# Copy bin files to PATH
# RUN cp $QEMU_PATH/build/qemu-system-xtensa /usr/local/bin/
# RUN cp $QEMU_PATH/build/qemu-img /usr/local/bin/
# RUN cp $QEMU_PATH/build/qemu-edid /usr/local/bin/

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************
RUN sudo apt-get update && \
    sudo apt-get install -y \
    git wget flex bison gperf python3 python3-pip python3-setuptools \
    cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0

RUN apt-get clean -y && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
RUN echo "source /opt/esp/idf/export.sh" >> /home/$USERNAME/.bashrc
RUN sudo usermod -aG dialout $USERNAME
RUN sudo chown -R $USERNAME:1001 /opt/esp

CMD ["/bin/bash"]