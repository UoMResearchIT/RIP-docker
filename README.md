# RIP-docker

## RIP Usage
The following information on how to use RIP is a *very* succint summary of the 
[docs](https://www2.mmm.ucar.edu/wrf/users/docs/ripug.htm) 
and 
[online tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/RIP4/index.php) 
from ucar, that can be followed directly from the **/SAMPLE** directory in the docker container. The 
[sample data](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/CASES/SingleDomain/wrf.php) 
to test is already contained there, but can also be directly downloaded from 
[ucar's website](https://www2.mmm.ucar.edu/wrf/TUTORIAL_DATA/single_domain/wrfout_d01.tar.gz)
.

### Prepare the data
The wrfout files will be pre-processed with ripdp. 
To run ripdp you first need a "namelist" file, that configures what ripdp will do.
Since ripdp will generate a lot of files, it is better to first create a directory for them.
```
mkdir RIPDP
```

A sample namelist file looks like this:

```
&userin
 ptimes=0,-72,1,ptimeunits='h',tacc=90.,discard='LANDMASK','H2SO4',
 iexpandedout=1
 &end
```
Save it inside the directory, and call it rdp_wrfarw.in. Then, run ripdp:

```
ripdp_wrfarw RIPDP/rdp_wrfarw.in all WRFData/wrfout_d01_*
```