FROM ubuntu:20.04

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get -y install ca-certificates gpg wget curl zip unzip tar ccache bison pkg-config libdbus-1-dev libxi-dev libxtst-dev libx11-dev libxft-dev libxext-dev libx11-dev libgles2-mesa-dev x11-xserver-utils xorg-dev libglu1-mesa-dev doxygen libjsoncpp-dev uuid-dev zlib1g-dev openssl libssl-dev
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal-rc main' | tee -a /etc/apt/sources.list.d/kitware.list >/dev/null

RUN apt-get update && apt-get install -y apt-utils python3 python3-pip git xvfb build-essential cmake

RUN git clone https://github.com/drogonframework/drogon
WORKDIR /drogon
RUN git submodule update --init 
RUN mkdir build
WORKDIR /drogon/build
RUN cmake ..
RUN make && make install
WORKDIR /

RUN git clone https://github.com/open-source-parsers/jsoncpp
WORKDIR /jsoncpp
RUN mkdir build
WORKDIR /jsoncpp/build
RUN cmake ..
RUN make && make install
WORKDIR /

# RUN git clone https://github.com/UIA-CAIR/DeepRTS.git drts --recurse-submodules
COPY . drts
RUN git config --global --add safe.directory /drts
RUN pip3 install -r /drts/requirements.txt
# RUN vcpkg update
RUN pip3 install -e drts
# -v /tmp/.X11-unix:/tmp/.X11-unix
# RUN cat drts/coding/requirements.txt | xargs -n 1 pip3 install; exit 0
# RUN cat drts/requirements.txt | xargs -n 1 pip3 install; exit 0

RUN Xvfb :99 -ac &

ENV SDL_VIDEODRIVER=dummy

# RUN python3 drts/main.py