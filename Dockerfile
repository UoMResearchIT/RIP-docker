#FROM continuumio/miniconda3
#RUN conda install -c conda-forge ncl c-compiler fortran-compiler cxx-compiler -y


FROM oliverwoolland/wrf_intermediate
#RUN apt-get -y update && apt-get -y install gcc gfortran

###################
### Install NCL with apt-get
RUN apt-get -y update && apt-get install -y ncl-ncarg

### Testing NCL
# ncl -V
## 6.6.2
# ncl /usr/share/ncarg/gsun/gsun/gsun02n.ncl
## !! --X driver error: DISPLAY environment variable not set
# ncl /usr/share/ncarg/nug/nug/NUG_multi_timeseries.ncl
## Successfully creates NUG_multi_timeseries.png file


### Configure RIP
RUN wget -c https://www2.mmm.ucar.edu/wrf/src/RIP_47.tar.gz \
 && tar -xzf RIP_47.tar.gz \
 && rm RIP_47.tar.gz
WORKDIR RIP_47
## Fix references to lib directories
RUN sed -i '27s|NETCDFLIB	= -L${NETCDF}/lib -lnetcdf CONFIGURE_NETCDFF_LIB|NETCDFLIB	= -L${NETCDF}lib CONFIGURE_NETCDFF_LIB -lnetcdf -lhdf5 -lhdf5_hl -lgfortran -lgcc |g' ./arch/preamble \
 && sed -i '31s|-L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB| -L${NCARG_ROOT} -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB -L</usr/lib/x86_64-linux-gnu>|g' ./arch/preamble \
 && sed -i '29s|NETCDFINC	= -I${NETCDF}/include|NETCDFINC	= -I${NETCDF}include|g' ./arch/preamble \
 && sed -i '36s|LOCAL_LIBS      = -L/usr/X11R6/lib64 -lX11|LOCAL_LIBS      = |g' ./arch/configure.defaults \
 && sed -i 's|NCARG_ROOT/lib|NCARG_ROOT|g' ./configure \
 && sed -i 's|NCARG_ROOT}/lib|NCARG_ROOT}|g' ./configure

ENV NCARG_ROOT=/usr/lib/x86_64-linux-gnu/ncarg/
RUN printf '3\n' | ./configure
## !! The Fortran compiler,  gfortran  is not consistent with the version of NCAR Graphics.

## Prevent compile warnings. "Fortran 2018 deleted feature: Shared DO termination label..." using an older fortran compiler
RUN apt-get -y install gfortran-8 \
 && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 20 \
 && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-9 10 \
 && sed -i '332s|printf("sizeof(v5dstruct)=%d|printf("sizeof(v5dstruct)=%lu|g' ./src/v5d.c
RUN ./compile 
#> log_compile.txt
## !! /bin/sh: 1: Syntax error: end of file unexpected
## !! make: [Makefile:44: rip] Error 2 (ignored)
###################

###################
### Install ncl through miniconda
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#  && bash ./Miniconda3-latest-Linux-x86_64.sh -bup && rm Miniconda3-latest-Linux-x86_64.sh 
# ENV PATH=/root/miniconda3/bin:$PATH
# RUN conda init bash \
#  && conda update -n root --all -y \
#  && conda install -c conda-forge ncl

### Testing NCL
# ncl -V
## 6.6.2
# ncl $NCARG_ROOT/lib/ncarg/nclex/gsun/gsun02n.ncl
## !! --X driver error: DISPLAY environment variable not set
# ncl $NCARG_ROOT/lib/ncarg/nclex/nug/NUG_multi_timeseries.ncl
## Successfully creates NUG_multi_timeseries.png file


### Configure RIP
# RUN wget -c https://www2.mmm.ucar.edu/wrf/src/RIP_47.tar.gz \
#  && tar -xzf RIP_47.tar.gz \
#  && rm RIP_47.tar.gz
# WORKDIR RIP_47

# ENV NCARG_ROOT=/root/miniconda3
# RUN printf '3\n' | ./configure 

## !! Your Fortran + NCAR Graphics did not run successfully

# RUN ./compile
###################


###################
### Install NCL using binaries
# WORKDIR /usr/local/ncl-6.6.2
# RUN wget -c https://www.earthsystemgrid.org/api/v1/dataset/ncl.662.dap/file/ncl_ncarg-6.6.2-CentOS6.10_64bit_gnu447.tar.gz
# RUN tar -zxf ncl_ncarg-6.6.2-CentOS6.10_64bit_gnu447.tar.gz
# RUN rm ncl_ncarg-6.6.2-CentOS6.10_64bit_gnu447.tar.gz
# ENV NCARG_ROOT=/usr/local/ncl-6.6.2
# ENV PATH=$NCARG_ROOT/bin:$PATH

### Testing NCL
# ncl -V
## !! error while loading shared libraries: libidn.so.11: cannot open shared object file: No such file or directory
# ncl $NCARG_ROOT/lib/ncarg/nclex/gsun/gsun02n.ncl
## !! 
# ncl $NCARG_ROOT/lib/ncarg/nclex/nug/NUG_multi_timeseries.ncl
## !! 

#RUN apt-get -y update && apt-get install -y xorg-dev libx11-dev libbz2-dev libcairo2-dev csh
###libcairo-devel??
###################