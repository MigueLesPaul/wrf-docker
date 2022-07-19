#!/bin/bash


# Inicializar las variablees de entorno
#source ./env


# set -euo pipefail
IFS=$'\n\t'


download_packages(){
    git clone https://github.com/erdc/szip $PREFIX/szip
    git clone https://github.com/madler/zlib $PREFIX/zlib
    git clone https://github.com/mortenpi/hdf5 $PREFIX/hdf5
    curl -L -S https://github.com/Unidata/netcdf-c/archive/v4.7.2.tar.gz -o $PREFIX/netcdf-4.7.2.tar.gz
    curl -L -S https://github.com/Unidata/netcdf-fortran/archive/v4.5.2.tar.gz -o $PREFIX/netcdf-fortran-4.5.2.tar.gz
    curl -L -S http://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz -o $PREFIX/mpich-3.3.tar.gz
    curl -L -S https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar -o $PREFIX/Fortran_C_tests.tar
    WRFVERSION=WRFV3.9.1
    wget -c http://www2.mmm.ucar.edu/wrf/src/${WRFVERSION}.TAR.gz -P $PREFIX
    curl -L -S http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz -o $PREFIX/libpng-1.2.50.tar.gz
    curl -L -S http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz -o $PREFIX/jasper-1.900.1.tar.gz
    wget -c http://www2.mmm.ucar.edu/wrf/src/WPSV3.9.1.TAR.gz -P $PREFIX
    curl -L -S http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz -o $PREFIX/ARWpost_V3.tar.gz
    
}

install_szip() {
    git clone https://github.com/erdc/szip $PREFIX/szip
    cd $PREFIX/szip
    echo "Starting configure for szip"
    ./configure --prefix=$PREFIX &> configure.log
    
    echo "Running make install"
    make
    make install &> install.log
}

install_zlib() {
    git clone https://github.com/madler/zlib $PREFIX/zlib
    cd $PREFIX/zlib
    echo "Starting Configure "
    ./configure --prefix=$PREFIX &> configure.log
    make
    make install &> install.log
}

install_hdf5() {
    git clone https://github.com/HDFGroup/hdf5.git $PREFIX/hdf5
    cd $PREFIX/hdf5\
    git checkout hdf5-1_10_4\
    ./configure \
    --prefix=$PREFIX \
    --with-zlib=$PREFIX \
    --with-szip=$PREFIX \
    --enable-fortran \
    --enable-cxx &> configure.log
    make
    make install &> install.log
}

install_netcdf_c() {
    curl -L -S https://github.com/Unidata/netcdf-c/archive/v4.7.2.tar.gz -o $PREFIX/netcdf-4.7.2.tar.gz
    tar zxvf $PREFIX/netcdf-4.7.2.tar.gz -C $PREFIX
    # rm $PREFIX/netcdf-4.7.2.tar.gz
    mv $PREFIX/netcdf-c-4.7.2 $PREFIX/netcdf-c
    cd $PREFIX/netcdf-c
    LD_LIBRARY_PATH=$PREFIX/lib CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib ./configure --prefix=$PREFIX --disable-dap --disable-netcdf-4 --disable-shared &> configure.log
    make
    make install &> install.log
}

install_netcdf_fortran() {
    curl -L -S https://github.com/Unidata/netcdf-fortran/archive/v4.5.2.tar.gz -o $PREFIX/netcdf-fortran-4.5.2.tar.gz
    tar zxvf $PREFIX/netcdf-fortran-4.5.2.tar.gz -C $PREFIX
    # rm $PREFIX/netcdf-fortran-4.5.2.tar.gz
    mv $PREFIX/netcdf-fortran-4.5.2 $PREFIX/netcdf-fortran
    cd $PREFIX/netcdf-fortran
    CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" LD_LIBRARY_PATH=$PREFIX/lib LIBS="-lnetcdf -lhdf5_hl -lhdf5 -lz " ./configure --disable-shared --prefix=$PREFIX &> configure.log
    make
    make install &> install.log
}

install_mpich() {
    curl -L -S http://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz -o $PREFIX/mpich-3.3.tar.gz
    curl -L -S http://www.mpich.org/static/downloads/3.3/mpich-3.3.tar.gz -o $PREFIX/mpich-3.3.tar.gz
    tar zxvf $PREFIX/mpich-3.3.tar.gz -C $PREFIX
    # rm $PREFIX/mpich-3.3.tar.gz
    mv $PREFIX/mpich-3.3 $PREFIX/mpich
    cd $PREFIX/mpich
    ./configure --prefix=$PREFIX &> configure.log
    make
    make install &> install.log
}

test_compilers(){
    
    curl -L -S https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar -o $PREFIX/Fortran_C_tests.tar
    tar -xvf $PREFIX/Fortran_C_tests.tar -C $PREFIX
    
    cd $PREFIX
    echo " "
    echo " "
    echo "Fixed format Fortran:"
    echo "TEST_1_fortran_only_fixed.f"
    
    gfortran TEST_1_fortran_only_fixed.f
    ./a.out
    
    echo " "
    echo "Free format Fortran:"
    echo "TEST_2_fortran_only_free.f90"
    
    gfortran TEST_2_fortran_only_free.f90
    ./a.out
    
    echo " "
    echo "C:"
    echo "TEST_3_c_only.c"
    echo " "
    gcc TEST_3_c_only.c
    ./a.out
    
    
    echo " "
    echo "Fortran calling a C function:"
    echo "Our gcc and gfortran have different defaults, so we force both to always use 64 bit (-m64) when combining them."
    echo "TEST_4_fortran+c_c.c"
    echo "TEST_4_fortran+c_f.f90"
    gcc -c -m64 TEST_4_fortran+c_c.c
    gfortran -c -m64 TEST_4_fortran+c_f.f90
    gfortran -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
    ./a.out
    
    echo " "
    echo "To check the scripting languages:"
    echo "csh:"
    ./TEST_csh.csh
    
    
    echo "perl:"
    ./TEST_perl.pl
    
    echo "sh:"
    ./TEST_sh.sh
    
    
    
    
}

install_wrf() {
    # WRFVERSION=WRFV4.0
    WRFVERSION=WRFV3.9.1
    wget -c http://www2.mmm.ucar.edu/wrf/src/${WRFVERSION}.TAR.gz -P $PREFIX
    tar -zxvf ${PREFIX}/${WRFVERSION}.TAR.gz -C $PREFIX
    #    rm -f $PREFIX/${WRFVERSION}.TAR.gz
    
    #    Cambiado codigo fuente, se aumento las dimensiones de la variable seed. En caso contrario no compila el codigo
    #    archivo WRFV3/phys/module_cu_g3.F   linea  3125
    cd $PREFIX/WRFV3
    # cd $PREFIX/WRF     ####  Version4
    echo $WRF_CONFIGURE_OPTION | ./configure &> configure.log
    ./compile em_real &> install.log
}

install_libpng() {
    curl -L -S http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz -o $PREFIX/libpng-1.2.50.tar.gz
    tar -zxvf $PREFIX/libpng-1.2.50.tar.gz -C $PREFIX
    # rm $PREFIX/libpng-1.2.50.tar.gz
    cd $PREFIX/libpng-1.2.50
    CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib ./configure --prefix=$PREFIX &> configure.log
    make
    make install &> install.log
}

install_jasper() {
    curl -L -S http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz -o $PREFIX/jasper-1.900.1.tar.gz
    tar -zxvf $PREFIX/jasper-1.900.1.tar.gz -C $PREFIX
    # rm $PREFIX/jasper-1.900.1.tar.gz
    cd $PREFIX/jasper-1.900.1
    ./configure --prefix=$PREFIX &> configure.log
    make
    make install &> install.log
}

install_wps() {
    wget -c http://www2.mmm.ucar.edu/wrf/src/WPSV3.9.1.TAR.gz -P $PREFIX
    tar zxvf $PREFIX/WPSV3.9.1.TAR.gz -C $PREFIX
    # rm $PREFIX/WPSV3.9.1.TAR.gz
    cd $PREFIX/WPS
    echo 1 | NCARG_ROOT=$PREFIX PATH=$NCARG_ROOT/bin:$PATH NETCDF=$PREFIX JASPERLIB=$PREFIX/lib JASPERINC=$PREFIX/include ./configure &> configure.log
    ./compile &> install.log
}

install_arwpost() {
    curl -L -S http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz -o $PREFIX/ARWpost_V3.tar.gz
    tar zxvf $PREFIX/ARWpost_V3.tar.gz -C $PREFIX
    # rm $PREFIX/ARWpost_V3.tar.gz
    cd $PREFIX/ARWpost
    echo $ARW_CONFIGURE_OPTION | ./configure --prefix=$PREFIX &> configure.log
    sed -i "s/-ffree-form -O/-ffree-form -O -cpp/" configure.arwp
    sed -i "s/-ffixed-form -O/-ffixed-form -O -cpp/" configure.arwp
    sed -i "s/-lnetcdf/-lnetcdff -lnetcdf/" src/Makefile
    ./compile &> install.log
}

#NOT INSTALLED
#
#install_g2lib() {
##    curl -L -S http://www.nco.ncep.noaa.gov/pmb/codes/GRIB2/g2lib-1.4.0.tar  -o $PREFIX/g2lib-1.4.0.tar
#    tar xvf $PREFIX/g2lib-1.4.0.tar -C $PREFIX
#    rm $PREFIX/g2lib-1.4.0.tar
#    cd $PREFIX/g2lib-1.4.0
#    sed -i "s:#.*$::g" makefile
#    sed -i "s/DEFS=.*/DEFS=-DLINUX/g" makefile
#    sed -i "s/g95/gfortran/g" makefile
#    sed -i "s/CC=.*/CC=gcc/g" makefile
#    sed -i "s|INCDIR=.*|INCDIR=-I"$PREFIX/include" -I"$PREFIX/include/jasper"|g" makefile
#    sed -i "s/ARFLAGS=.*/ARFLAGS=rUv/" makefile
#    sed -i "s/-ruv//" makefile
#    make &> install.log
#    cp libg2.a $PREFIX/lib
#}
#
#install_w3lib() {
##    curl -L -S http://www.nco.ncep.noaa.gov/pmb/codes/GRIB2/w3lib-2.0.2.tar  -o $PREFIX/w3lib-2.0.2.tar
#    tar xvf $PREFIX/w3lib-2.0.2.tar -C $PREFIX
#    rm $PREFIX/w3lib-2.0.2.tar
#    cd $PREFIX/w3lib-2.0.2
#    sed -i "s:#.*$::g" Makefile
#    sed -i "s/g95/gfortran/g" Makefile
#    sed -i "s/CC.*= cc/CC = gcc/g" Makefile
#    sed -i "s/ARFLAGS =.*/ARFLAGS = rUv/" Makefile
#    sed -i "s/-ruv//" Makefile
#    make &> install.log
#    cp libw3.a $PREFIX/lib
#}
#
#install_g95() {
##    wget http://ftp.g95.org/v0.93/g95-x86_64-64-linux.tgz -P $PREFIX
#    tar zxvf $PREFIX/g95-x86_64-64-linux.tgz -C $PREFIX
#    ln  -s $PREFIX/g95-install/bin/x86_64-unknown-linux-gnu-g95 $PREFIX/bin/g95
#}
#
#install_cnvgrib() {
##    curl -L -S http://www.nco.ncep.noaa.gov/pmb/codes/GRIB2/cnvgrib-1.4.1.tar  -o $PREFIX/cnvgrib-1.4.1.tar
#    tar xvf $PREFIX/cnvgrib-1.4.1.tar -C $PREFIX
#    rm $PREFIX/cnvgrib-1.4.1.tar
#    cd $PREFIX/cnvgrib-1.4.1
#    sed -i "s:#.*$::g" makefile
#    sed -i "s/g95/gfortran/g" makefile
#    sed -i "s|LIBS =.*|LIBS = -L"$PREFIX/lib" -lg2 -lw3 -ljasper -lpng -lz|" makefile
#    sed -i "/LIBS =.*/{n;N;N;d}" makefile
#    sed -i "s|INC =.*|INC = -I"$PREFIX/include" -I"$PREFIX/g2lib-1.4.0" -I"$PREFIX/include/jasper"|" makefile
#    make &> install.log
#}

install_all() {
    download_packages
    install_szip
    install_zlib
    install_mpich
    install_hdf5
    install_netcdf_c
    install_netcdf_fortran
  
    test_compilers
    install_wrf
    install_libpng
    install_jasper
    install_wps
    install_arwpost
}




# if [ ! -d /home/wrf/data ]; then
#     mkdir /home/wrf/data
# fi

# install_all


