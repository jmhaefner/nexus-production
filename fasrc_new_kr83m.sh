#!/bin/bash

#SBATCH -J nexus_new_kr83m  # A single job name for the array
#SBATCH -n 1                # Number of cores
#SBATCH -N 1                # All cores on one machine
#SBATCH -p guenette         # Partition
#SBATCH --mem 500           # Memory request (Mb)
#SBATCH -t 0-2:00           # Maximum execution time (D-HH:MM)
#SBATCH -o %A_%a.out        # Standard output
#SBATCH -e %A_%a.err        # Standard error

## Job options
RNDSEED=${SLURM_ARRAY_TASK_ID}
NEVENTS=1000
STARTID=$((RNDSEED*1000))
OUTFILE="/n/holyscratch01/guenette_lab/new.kr83m.nexus.${SLURM_ARRAY_TASK_ID}"

## Configure scisoft software products
. /n/holylfs02/LABS/guenette_lab/software/next/scisoft/setup
setup hdf5   v1_10_5     -q e19
setup root   v6_18_04    -q e19:prof
setup geant4 v4_10_6_p01 -q e19:prof

## Generate nexus macros
INI_MACRO="/n/holyscratch01/guenette_lab/nexus.init.${SLURM_ARRAY_TASK_ID}.mac"
CFG_MACRO="/n/holyscratch01/guenette_lab/nexus.config.${SLURM_ARRAY_TASK_ID}.mac"

echo "/PhysicsList/RegisterPhysics G4EmStandardPhysics_option4" >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4DecayPhysics"              >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4RadioactiveDecayPhysics"   >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4OpticalPhysics"            >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics NexusPhysics"                >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4StepLimiterPhysics"        >> ${INI_MACRO}
echo "/Geometry/RegisterGeometry NEXT_NEW"                      >> ${INI_MACRO}
echo "/Generator/RegisterGenerator Kr83m"                       >> ${INI_MACRO}
echo "/Actions/RegisterRunAction      DEFAULT"                  >> ${INI_MACRO}
echo "/Actions/RegisterEventAction    DEFAULT"                  >> ${INI_MACRO}
echo "/Actions/RegisterTrackingAction DEFAULT"                  >> ${INI_MACRO}
echo "/nexus/RegisterMacro ${CFG_MACRO}"                        >> ${INI_MACRO}
echo " "                                                        >> ${INI_MACRO}

echo "/run/verbose      0"                                      >> ${CFG_MACRO}
echo "/event/verbose    0"                                      >> ${CFG_MACRO}
echo "/tracking/verbose 0"                                      >> ${CFG_MACRO}
echo "/Generator/Kr83mGenerator/region ACTIVE"                  >> ${CFG_MACRO}
echo "/Geometry/NextNew/pressure 10.2 bar"                      >> ${CFG_MACRO}
echo "/Geometry/NextNew/sc_yield 25510. 1/MeV"                  >> ${CFG_MACRO}
echo "/Geometry/NextNew/EL_field 12.8 kilovolt/cm"              >> ${CFG_MACRO}
echo "/Geometry/NextNew/drift_transv_diff 1.2 mm/sqrt(cm)"      >> ${CFG_MACRO}
echo "/Geometry/NextNew/drift_long_diff   0.3 mm/sqrt(cm)"      >> ${CFG_MACRO}
echo "/Geometry/NextNew/elfield true"                           >> ${CFG_MACRO}
echo "/Geometry/NextNew/max_step_size 1. m"                     >> ${CFG_MACRO}
echo "/Geometry/PmtR11410/SD_depth 4"                           >> ${CFG_MACRO}
echo "/Geometry/PmtR11410/time_binning 1. nanosecond"           >> ${CFG_MACRO}
echo "/Geometry/SiPMSensl/time_binning 1. microsecond"          >> ${CFG_MACRO}
echo "/Geometry/KDB/teflon_masks true"                          >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/clustering true"                       >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/drift true"                            >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/electroluminescence true"              >> ${CFG_MACRO}
echo "/nexus/random_seed ${RNDSEED}"                            >> ${CFG_MACRO}
echo "/nexus/persistency/start_id ${STARTID}"                   >> ${CFG_MACRO}
echo "/nexus/persistency/outputFile ${OUTFILE}"                 >> ${CFG_MACRO}
echo " "                                                        >> ${CFG_MACRO}

/n/holylfs02/LABS/guenette_lab/software/next/nexus/master/build/source/nexus -b -n ${NEVENTS} ${INI_MACRO}
cp "${OUTFILE}.h5" /n/holylfs02/LABS/guenette_lab/data/NEXT
