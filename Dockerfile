# syntax=docker/dockerfile:1.4.2

FROM oliverwoolland/wrf_intermediate

### Change shell to be able to source and use conda envs.
SHELL ["/bin/bash", "-c"]

###################
### Install ncl through miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
 && bash ./Miniconda3-latest-Linux-x86_64.sh -bup && rm Miniconda3-latest-Linux-x86_64.sh 
ENV PATH=/root/miniconda3/bin:$PATH
RUN conda init bash \
 && conda update -n root --all -y \
 && conda create --name ncl_stable -c conda-forge ncl c-compiler fortran-compiler cxx-compiler -y

### Configure RIP
RUN wget -c https://www2.mmm.ucar.edu/wrf/src/RIP_47.tar.gz \
 && tar -xzf RIP_47.tar.gz \
 && rm RIP_47.tar.gz
WORKDIR RIP_47
### Fix references to lib directories
#RUN sed -i '27s|NETCDFLIB	= -L${NETCDF}/lib -lnetcdf CONFIGURE_NETCDFF_LIB|NETCDFLIB	= -L${NETCDF}lib CONFIGURE_NETCDFF_LIB -lnetcdf -lhdf5 -lhdf5_hl -lgfortran -lgcc |g' ./arch/preamble \
# && sed -i '31s|-L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB| -L${NCARG_ROOT} -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB -L</usr/lib/x86_64-linux-gnu>|g' ./arch/preamble \      ***
# && sed -i '29s|NETCDFINC	= -I${NETCDF}/include|NETCDFINC	= -I${NETCDF}include|g' ./arch/preamble \
# && sed -i '36s|LOCAL_LIBS      = -L/usr/X11R6/lib64 -lX11|LOCAL_LIBS      = |g' ./arch/configure.defaults \       ***
# && sed -i 's|NCARG_ROOT/lib|NCARG_ROOT|g' ./configure \
# && sed -i 's|NCARG_ROOT}/lib|NCARG_ROOT}|g' ./configure
# *** Using these 2 lines instead of line 31 made the "unexpected end of file" error appear.
RUN sed -i '27s|NETCDFLIB	= -L${NETCDF}/lib -lnetcdf CONFIGURE_NETCDFF_LIB|NETCDFLIB	= -L</usr/lib/x86_64-linux-gnu/libm.a> -lm -L${NETCDF}/lib CONFIGURE_NETCDFF_LIB -lnetcdf -lhdf5 -lhdf5_hl -lgfortran -lgcc -lz |g' ./arch/preamble \
 && sed -i '31s|-L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB| -L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz -lcairo -lfontconfig -lpixman-1 -lfreetype -lexpat -lpthread -lbz2 -lXrender -lgfortran -lgcc -L</usr/lib/x86_64-linux-gnu/> -lm -lhdf5 -lhdf5_hl |g' ./arch/preamble \
 && sed -i '33s| -O|-fallow-argument-mismatch -O |g' ./arch/configure.defaults 
 # Still have some duplicate lib calls for: -lhdf5 -lhdf5_hl -lgfortran -lgcc -lz -lm -lX11
 
#ENV NCARG_ROOT=/usr/lib/x86_64-linux-gnu/ncarg/
RUN source /root/miniconda3/etc/profile.d/conda.sh && conda activate ncl_stable && printf '3\n' | ./configure
## !! Your Fortran + NCAR Graphics did not run successfully.

## Prevent compile warnings. "Fortran 2018 deleted feature: Shared DO termination label..." using an older fortran compiler
#conda install gfortran_linux-64=8.4.0
# RUN source /root/miniconda3/etc/profile.d/conda.sh && conda activate ncl_stable \
#  && conda install -y -c conda-forge gfortran-8 \
#  && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 20 \
#  && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-9 10
# && sed -i '332s|printf("sizeof(v5dstruct)=%d|printf("sizeof(v5dstruct)=%lu|g' ./src/v5d.c
RUN source /root/miniconda3/etc/profile.d/conda.sh && conda activate ncl_stable && ./compile > log_compile.txt
## !! Warning: Type mismatch between actual argument at (1) and actual argument at (2) (INTEGER(4)/CHARACTER(*)).
## !! Warning: Fortran 2018 deleted feature: Shared DO termination label
## !! Warning: Fortran 2018 deleted feature: Arithmetic IF statement