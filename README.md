# RIP-docker

## Running the container
For some functionality the docker container might need the display, and so it is reccommended that the container is run with the following options:
```
docker run -it --network=host -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --privileged --rm fcoherreazcue/ripdocker
```

## RIP Usage
The following information on how to use RIP is a *very* succint summary of the 
[docs](https://www2.mmm.ucar.edu/wrf/users/docs/ripug.htm) 
and 
[online tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/Graphics/RIP4/index.php) 
from ucar, that can be followed directly from the **/SAMPLE** directory in the docker container. The 
[sample data](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/CASES/SingleDomain/wrf.php) 
to test is already at **/SAMPLE/WRFData**, but can also be directly downloaded from 
[ucar's website](https://www2.mmm.ucar.edu/wrf/TUTORIAL_DATA/single_domain/wrfout_d01.tar.gz)
.

It is important to make sure that your ncl_stable environment is active before using rip. To activate it, run
```
conda activate ncl_stable
```
Also, make sure that you are in the directory with your .in files. For the sample run, this is
```
cd /Sample
```

### Prepare the data
The wrfout files will be pre-processed with ripdp. 
To run ripdp you first need a "namelist" file, that configures what ripdp will do.
Since ripdp will generate a lot of files, it is better to first create a directory for them.
For the case of the sample run, the directory **/SAMPLE/RIPDP** has already been created.

A sample namelist file is already saved in the **RIPDP** directory, under the name ***rdp_sample***.
We can then run ripdp as:

```
ripdp_wrfarw RIPDP/rdp_sample all WRFData/wrfout_d01_*
```

This should have created a lot of files inside RIPDP, called rdp_sample_XXX_YYY, where XXX is the time and YYY the name of the WRF variable in each file. 
This is the data that RIP needs to run, so we are now ready to use it.

### Running RIP
Now that we have pre-processed data, we need to configure rip. 
We do this using a "User Input File". A sample file called ***rip_sample.in*** is already at **/SAMPLE**.

Using this file, we can run rip as:
```
rip -f RIPDP/rdp_sample rip_sample.in
```

This should create a log file called ***rip_sample.out***, and a ***rip_sample.cgm*** file, with the generated plots.

The plots can be saved to a *pdf* format instead of *cgm* if in the user input file we set ***ncarg_type='pdf'*** (line 9)

### Back trajectories
Sample input files to compute back-trajectories can be found in **/SAMPLE/BackTraj**.
Note that there are 3 almost identical files called ***traj_.in***. These files have the flag ***itrajcalc=1***, which tells RIP that they will calculate trajectories. Running
```
cd /Sample/BackTraj
rip -f /Sample/RIPDP/rdp_sample traj1.in
rip -f /Sample/RIPDP/rdp_sample traj2.in
rip -f /Sample/RIPDP/rdp_sample traj3.in
```
will create the trajectories from the 3 different starting points (note that *zktraj* is different in each file). Files with endings '.diag', '.out' and '.traj' should have been generated.

We can now plot these trajectories with ***traj_plot.in*** by running
```
rip -f /Sample/RIPDP/rdp_sample traj_plot.in
```

### Visualizing the results

To be able to see the plots in **cgm** files, we need to use **idt**, by running
```
idt /Sample/rip_sample.cgm
```