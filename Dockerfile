FROM ubuntu:xenial
MAINTAINER Manuel Fuentes Jimenez<m92fuentes@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
COPY jodo /bin/
COPY proxy.conf /etc/apt/apt.conf.d/
RUN  apt-get update 
RUN  apt-get install -y software-properties-common \
    && add-apt-repository 'deb http://es.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse' \
#    &&  add-apt-repository ppa:ubuntugis/ppa \
#    &&  apt-get update \
    && apt-get install -y \
       autoconf \
       autotools-dev \
       build-essential

RUN apt-get install -y \
    csh \
    gfortran \
    gfortran-5-multilib \
    git \
    grads \
    imagemagick \
    libcloog-ppl1 \
    libg2-dev \
    libg20 \
    libgrib2c-dev \
    libjasper-dev \
    libjasper1 \
    libjpeg-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libopenjp2-7 \
    libopenjp2-7-dev \
    libsystemd-dev \
    libudunits2-dev \
    libx11-6 \
    libxaw7 \
    m4 \
    ncl-ncarg \
    tcsh \
    wget \
    python \
    python-matplotlib \
    python-numpy \
    python3 \
    python3-matplotlib \
    python3-numpy \
    curl

RUN apt-get install -y \
       python \
       python-matplotlib \
       python-numpy \
    && rm -rf /var/lib/apt/lists/*

ENV PREFIX /home/wrf
WORKDIR /home/wrf
ENV DEBIAN_FRONTEND noninteractive
ENV CC gcc
ENV CPP /lib/cpp -P
ENV CXX g++
ENV FC gfortran
ENV FCFLAGS -m64
ENV F77 gfortran
ENV FFLAGS -m64
ENV NETCDF $PREFIX
ENV NETCDFPATH $PREFIX
ENV WRF_CONFIGURE_OPTION 34
ENV WRF_EM_CORE 1
ENV WRF_NMM_CORE 0
ENV LD_LIBRARY_PATH_WRF $PREFIX/lib/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH_WRF
ENV NCARG_ROOT=$PREFIX
ENV JASPERLIB=$PREFIX/lib
ENV JASPERINC=$PREFIX/include
ENV ARW_CONFIGURE_OPTION 3
ENV PYTHONPATH $PREFIX/lib/python2.7/site-packages
ENV PATH $PATH:$PREFIX/bin:$NCARG_ROOT/bin:$PREFIX/WPS:$PREFIX/WRFV3/test/em_real:$PREFIX/WRFV3/main:$PREFIX/WRFV3/run:$PREFIX/WPS:$PREFIX/ARWpost:$PREFIX
ENV HTTPS_PROXY=http://miguel.hinojosa:CoalBitminer@10.0.100.191:3128/
ENV HTTP_PROXY=http://miguel.hinojosa:CoalBitminer@10.0.100.191:3128/

RUN mkdir -p /home/wrf && \
    useradd wrf -d /home/wrf && \
    chown -R wrf:wrf /home/wrf
RUN ulimit -s unlimited
USER wrf
COPY build.sh /home/wrf
COPY .gitconfig /home/wrf
COPY .wgetrc /home/wrf

RUN ./build.sh
COPY entrypoint.sh $PREFIX
ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"]
VOLUME /home/wrf/data
