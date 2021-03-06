#!/bin/bash

##### ##### ##### x_BGC_iniWriter.sh 
##### ##### William J Matthaeus April 2022
#this software is provded as-is and comes with no guarantees
#for assistance please contact the author at willmatt@udel.edu
#
#the general scheme is that input filenames contain information about the runs to be
#performed.
#
#iniWriter functions to create ini files in a parameterized fashion, creates an
#an individual PBS command file for each simulation, and submits that simulation to PBS
#
#iniWriter is intended to take inputs from upstream software that
#1)creates input files with systematic names (e.g., cesm_to_mtc43.ncl)
#and then 2) 
#
#the details of how this should be done will depend on the filenames generated,
#therefore some alternative examples are left in the comments


####constants, for things you want to hardcode
#check they're redundant with assignments below, 
#make sure you're not 
#assigning things twice by accident
#e.g., if we're doing 'Location A'
# export LAT=0
#set the following to zero to 'turn off' plants
export ILC=0.01

####assign in/out files from arguments
#BATCHDIR should identify the current batch of experiments, passed from x_BGC_Launcher
#
#inputs in order are Metfile EPCfile Data_BatchDir BinDir Binary METdir EPCdir
#
export METF=$1      #e.g., GLAC_182_28_A.mtc43, or 1x_280_140_0.947368.mtc43
export EPCF=$2      #e.g., cordaites_MEDCN_MEDg.epc
export BATCHDIR=$3  #e.g., /home/matthaeusw/paleo_model/st_083021
export BINDIR=$4    #e.g., /home/matthaeusw/paleo_model
export BINARY=$5    #e.g., bgc
export METD=$6      #e.g., metdata
export EPCD=$7      #e.g., epc

#example file name formats:
#METF: CO2x_CO2ppm_LON_LAT.mtc43 , or GLAC_CO2_O2_LOCATION.mtc43
#EPCF: SP_CN_g.epc

###removing file extension
#export METF=$(echo ${METFF} | awk -F/ '{print $(NF-1)}')
#taking off the file extension from met,epc file. awk ok for some things
# export MET=$(echo ${METF} | awk -F'[.]' '{print $1}')
# export EPC=$(echo ${EPCF} | awk -F'[.]' '{print $1}')
#below is robust to multiple '.'s in filenames from lon/lat decimal degrees,
#reverses filename and takes second to last token delimited by '.'
export MET=$(echo $METF | rev  | cut -d '.' -f2- | rev)
export EPC=$(echo $EPCF | rev  | cut -d '.' -f2- | rev )


####named variables are declared in the order they are used below
####setup MET variables from current arguments
#MET: CO2x_CO2ppm_LON_LAT.mtc43 (i.e., from met.bak.1xCO2 or met.bak.2xCO2)
#
#EPC: SP_CN_g
#
#change 'n' in awk print $n command to change field
# export LAT=$(echo ${MET} | cut -d '_' -f2)
# export O2VERSION=$(echo ${MET} | awk -F'[_]' '{print $3}')
# export GLAC=$(echo ${MET} | awk -F'[_]' '{print $1}')
#
export LAT=$(echo ${MET} | awk -F'[_]' '{print $4}')
export LON=$(echo ${MET} | awk -F'[_]' '{print $3}')
export CO2=$(echo ${MET} | awk -F'[_]' '{print $2}')


#setup variables from EPC would look much the same
# export g=$(echo ${EPC} | awk -F'[_]' '{print $3}')
# #export K=$
# export CN=$(echo ${EPC} | awk -F'[_]' '{print $2}')

#example of a conditional approach for translating
#filenames in situations with limited cases encoded non-numerically
#assign LAT based on MET.. switch?
# case $ZONE in
#     A ) export LAT=0;;
#     B ) export LAT=0;;
#     C ) export LAT=24;;
#     D ) export LAT=-30;;
#     Z ) export LAT=20;;
#     * ) echo "Error: No Lat Assigned";;
# esac


#setup the directory for this particular run 
#ini, restart, and output are experiment specific. put them in DIR
export DIR=${MET}_${EPC}
#the following line is just for code legibility
export PREFIX=$DIR

###test to abort if directory exists
#[ "$?" = "0" ]
if mkdir ${BATCHDIR}/${DIR}; then
	echo "We made ${BATCHDIR}/${DIR}"
else
	echo "Cannot make ${BATCHDIR}/${DIR}" 1>&2
	exit 1
fi
#make sub-directories
mkdir ${BATCHDIR}/${DIR}/outputs
mkdir ${BATCHDIR}/${DIR}/restart
mkdir ${BATCHDIR}/${DIR}/ini
#
cd ${BATCHDIR}/${DIR}
if [ "$?" != "0" ]; then
	echo "Cannot cd to ${BATCHDIR}/${DIR}" 1>&2
	exit 1
fi

###print .ini. hardcode inputs common to all experiments
###use variables defined above for inputs that vary
#allMETs_${GLAC}_${CO2}_${O2VERSION}
#other things that can go in file paths: ${CO2}_${O2VERSION}

##example for parametrically varying parameters like the precip multiplier using 
#shell
#uncomment the following several lines before 'echo' and uncomment the extra'done' 
#at the very end

# PRCPS=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
# PRCPN=(0pt1 0pt2 0pt3 0pt4 0pt5 0pt6 0pt7 0pt8 0pt9 1pt0)
# #loop prototype to check your variables
# #for i in $(seq 0 1 9); do echo "${i} : ${PRCPS[i]}"; done
# 
# for i in $(seq 0 1 9)
# do
echo "Biome-BGC v4.1.2 example : (normal simulation, Paleo template)

MET_INPUT     (keyword) start of meteorology file control block
../../${METD}/${METF}  meteorology input filename
1             (int)     header lines in met file

RESTART       (keyword) start of restart control block
1             (flag)    1 = read restart file     0 = don't read restart file
0             (flag)    1 = write restart file    0 = don't write restart file
0             (flag)    1 = use restart metyear   0 = reset metyear
restart/${PREFIX}.endpoint    input restart filename
restart/${PREFIX}.endpoint   output restart filename

TIME_DEFINE   (keyword - do not remove)
10            (int)       number of meteorological data years
50            (int)       number of simulation years
2000          (int)       first simulation year
0             (flag)      1 = spinup simulation    0 = normal simulation
10000         (int)       maximum number of spinup years (if spinup simulation)

CLIM_CHANGE   (keyword - do not remove)
0.0           (deg C)   offset for Tmax
0.0           (deg C)   offset for Tmin
1.0           (DIM)     multiplier for Prcp
1.0           (DIM)     multiplier for VPD
1.0           (DIM)     multiplier for shortwave radiation

CO2_CONTROL   (keyword - do not remove)
0             (flag)    0=constant 1=vary with file 2=constant, file for Ndep
${CO2}           (ppm)     constant atmospheric CO2 concentration
xxxxxxxxxxx   (file)    annual variable CO2 filename

SITE          (keyword) start of site physical constants block
0.5           (m)       effective soil depth (corrected for rock fraction)
30.0          (%)       sand percentage by volume in rock-free soil
50.0          (%)       silt percentage by volume in rock-free soil
20.0          (%)       clay percentage by volume in rock-free soil
100.0         (m)       site elevation
0.0           (degrees) site latitude (- for S.Hem.)
0.2           (DIM)     site shortwave albedo
0.0001        (kgN/m2/yr) wet+dry atmospheric deposition of N
0.0004        (kgN/m2/yr) symbiotic+asymbiotic fixation of N

RAMP_NDEP     (keyword - do not remove)
0             (flag) do a ramped N-deposition run? 0=no, 1=yes
2099          (int)  reference year for industrial N deposition
0.0000        (kgN/m2/yr) industrial N deposition value

EPC_FILE      (keyword - do not remove)
../../${EPCD}/${EPCF}    (file) evergreen broadleafed forest ecophysiological constants

W_STATE       (keyword) start of water state variable initialization block
0.0           (kg/m2)   water stored in snowpack
0.5           (DIM)     initial soil water as a proportion of saturation

C_STATE       (keyword) start of carbon state variable initialization block
${ILC}          (kgC/m2)  first-year maximum leaf carbon 
0.0           (kgC/m2)  first-year maximum stem carbon
0.0           (kgC/m2)  coarse woody debris carbon
0.0           (kgC/m2)  litter carbon, labile pool
0.0           (kgC/m2)  litter carbon, unshielded cellulose pool
0.0           (kgC/m2)  litter carbon, shielded cellulose pool
0.0           (kgC/m2)  litter carbon, lignin pool
0.0           (kgC/m2)  soil carbon, fast microbial recycling pool
0.0           (kgC/m2)  soil carbon, medium microbial recycling pool
0.0           (kgC/m2)  soil carbon, slow microbial recycling pool
0.0           (kgC/m2)  soil carbon, recalcitrant SOM (slowest)

N_STATE       (keyword) start of nitrogen state variable initialization block
0.0           (kgN/m2)  litter nitrogen, labile pool
0.0           (kgN/m2)  soil nitrogen, mineral pool

OUTPUT_CONTROL   (keyword - do not remove)
outputs/${PREFIX}_${PRCPN[i]}PRCP  (text) prefix for output files
1   (flag)  1 = write daily output   0 = no daily output
1   (flag)  1 = monthly avg of daily variables  0 = no monthly avg
1   (flag)  1 = annual avg of daily variables   0 = no annual avg
1   (flag)  1 = write annual output  0 = no annual output
1   (flag)  for on-screen progress indicator

DAILY_OUTPUT     (keyword)
58     (int) number of daily variables to output
20     0 ws.soilw
21     1 ws.snoww
38     2 wf.canopyw_evap
40     3 wf.snoww_subl
42     4 wf.soilw_evap
43     5 wf.soilw_trans
44     6 wf.soilw_outflow
50     7 cs.leafc
53     8 cs.frootc
56     9 cs.livestemc
59     10 cs.deadstemc
62     11 cs.livecrootc
65     12 cs.deadcrootc
280    13 ns.leafn
283    14 ns.frootn
286    15 ns.livestemn
289    16 ns.deadstemn
292    17 ns.livecrootn
295    18 ns.deadcrootn
509    19 epv.proj_lai
515    20 epv.psi
548    21 epv.psi_leaf
528    22 epv.daily_net_nmin
432    23 nf.sminn_leached
539    24 epv.gl_s_sun
540    25 epv.gl_s_shade
547    26 epv.m_Kl
566    27 psn_sun.g
568    28 psn_sun.Ci
570    29 psn_sun.Ca
579    30 psn_sun.A
549    31 epv.d13C_leaf_sun
596    32 psn_shade.g
598    33 psn_shade.Ci
600    34 psn_shade.Ca
609    35 psn_shade.A
550    36 epv.d13C_leaf_shade
620    37 summary.daily_npp
621    38 summary.daily_nep
622    39 summary.daily_nee
623    40 summary.daily_gpp
624    41 summary.daily_mr
625    42 summary.daily_gr
626    43 summary.daily_hr
636    44 summary.vegc
637    45 summary.litrc
638    46 summary.soilc
639    47 summary.totalc
647    48 summary.vegn
648    49 summary.litrn
649    50 summary.soiln
650    51 summary.totaln
0      52 metv.prcp
2      53 metv.tmin
577    54 psn.Av
578    55 psn.Aj
519    56 gl_t_wv_sun
520    57 gl_t_wv_shade


ANNUAL_OUTPUT    (keyword)
6       (int)   number of annual output variables
545     0 annual maximum projected LAI
636     1 vegetation C
637     2 litter C
638     3 soil C
639     4 total C
307     5 soil mineral N

END_INIT      (keyword) indicates the end of the initialization file
"> ${BATCHDIR}/${DIR}/ini/${PREFIX}_${PRCPN[i]}PRCP.ini

##make a script to submit to cluster, runs the model
echo "
cd ${BATCHDIR}/${DIR}

../../${BINARY} -ag ini/${PREFIX}_${PRCPN[i]}PRCP.ini
" > ${BATCHDIR}/${DIR}/Q_${PREFIX}_${PRCPN[i]}PRCP
#_${O2VERSION} to add to bgc call if neccessary if you're doing multiple versions
#that you want to automatically connect to met files
#bgc${O2VERSION} -ag ${BINDIR}/ini/${PREFIX}.ini

qsub ${BATCHDIR}/${DIR}/Q_${PREFIX}_${PRCPN[i]}PRCP
#uncomment the 'done' below if you're doing a loop based experiment, the above should work
#as the precip variables should be empty
# done 
