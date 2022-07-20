FROM ubuntu:xenial
MAINTAINER Manuel Fuentes Jimenez<m92fuentes@gmail.com>, Miguel Hinojosa<miguelhinojosa994@gmail.com>

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
ENV CC gcc -fPIC
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
RUN git config --global --add http.proxy http://miguel.hinojosa:CoalBitminer@10.0.100.191:3128
RUN git config --global --add https.proxy http://miguel.hinojosa:CoalBitminer@10.0.100.191:3128

ENV WRFVERSION=WRFV3.9.1

RUN mkdir -p /home/wrf && \
    useradd wrf -d /home/wrf && \
    chown -R wrf:wrf /home/wrf
RUN ulimit -s unlimited
USER wrf
COPY build.sh /home/wrf
COPY .wgetrc /etc/wgetrc


#Download Libraries    #fijarse en la versión de WPS
#RUN 
#
#    && 
#    && curl -L -S https://github.com/Unidata/netcdf-c/archive/v4.7.2.tar.gz -o $PREFIX/netcdf-4.7.2.tar.gz\
#    && curl -L -S https://github.com/Unidata/netcdf-fortran/archive/v4.5.2.tar.gz -o $PREFIX/netcdf-fortran-4.5.2.tar.gz\
#    && curl -L -S http://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz -o $PREFIX/mpich-3.3.tar.gz\
#    && curl -L -S https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar -o $PREFIX/Fortran_C_tests.tar\
#    && wget -c http://www2.mmm.ucar.edu/wrf/src/${WRFVERSION}.TAR.gz -P $PREFIX\
#    && curl -L -S http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz -o $PREFIX/libpng-1.2.50.tar.gz\
#    && curl -L -S http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz -o $PREFIX/jasper-1.900.1.tar.gz\
#    && wget -c http://www2.mmm.ucar.edu/wrf/src/WPSV3.9.1.TAR.gz -P $PREFIX\                                                                       
#    && curl -L -S http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz -o $PREFIX/ARWpost_V3.tar.gz



# Install szip
RUN git clone https://github.com/erdc/szip $PREFIX/szip

RUN cd $PREFIX/szip\
    && echo "Starting configure for szip"\
    && ./configure --prefix=$PREFIX &> configure.log
#    && echo "Running make install"\
#    && make\
#    && make install &

# # Install zlib
# RUN git clone https://github.com/madler/zlib $PREFIX/zlib\
#     && cd $PREFIX/zlib\
#     && echo "Starting Configure "\
#     && ./configure --prefix=$PREFIX &> configure.log\
#     && make\
#     && make install &

# # Install HDF5
# RUN git clone https://github.com/mortenpi/hdf5 $PREFIX/hdf5\
#     && cd $PREFIX/hdf5\
#     && ./configure \
#     && --prefix=$PREFIX \
#     && --with-zlib=$PREFIX \
#     && --with-szip=$PREFIX \
#     && --enable-fortran \
#     && --enable-cxx &> configure.log\
#     && make\
#     && make install &> install.log


# # iNSTALL NetCDF
# RUN curl -L -S https://github.com/Unidata/netcdf-c/archive/v4.7.2.tar.gz -o $PREFIX/netcdf-4.7.2.tar.gz\ 
#     && tar zxvf $PREFIX/netcdf-4.7.2.tar.gz -C $PREFIX\
#     # rm $PREFIX/netcdf-4.7.2.tar.gz\
#     && mv $PREFIX/netcdf-c-4.7.2 $PREFIX/netcdf-c\
#     && cd $PREFIX/netcdf-c\
#     && LD_LIBRARY_PATH=$PREFIX/lib CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib ./configure --prefix=$PREFIX --disable-dap --disable-netcdf-4 --disable-shared &> configure.log\
#     && make\
#     && make install &> install.log

#RUN ./build.sh
#COPY entrypoint.sh $PREFIX
#ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"]
VOLUME /home/wrf/data
