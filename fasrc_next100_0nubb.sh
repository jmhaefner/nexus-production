#!/bin/bash

#SBATCH -J nexus        # A single job name for the array
#SBATCH -n 1            # Number of cores
#SBATCH -N 1            # All cores on one machine
#SBATCH -p guenette     # Partition
#SBATCH --mem 250       # Memory request (Mb)
#SBATCH -t 0-15:00      # Maximum execution time (D-HH:MM)
#SBATCH -o %A_%a.out    # Standard output
#SBATCH -e %A_%a.err    # Standard error

## Job options
RNDSEED=${SLURM_ARRAY_TASK_ID}
PRODNUM=20200615
NEVENTS=10
STARTID=$(((RNDSEED-1)*NEVENTS))
OUTFILE="/n/holyscratch01/guenette_lab/jmartinalbo/next100.0nubb.${SLURM_ARRAY_TASK_ID}.nexus"

## Configure scisoft software products
. /n/holystore01/LABS/guenette_lab/Lab/software/next/scisoft/setup
setup hdf5   v1_10_5     -q e19
setup root   v6_18_04    -q e19:prof
setup geant4 v4_10_6_p01 -q e19:prof

## Generate nexus macros
INI_MACRO="/n/holyscratch01/guenette_lab/jmartinalbo/${PRODNUM}.${SLURM_ARRAY_TASK_ID}.init.mac"
CFG_MACRO="/n/holyscratch01/guenette_lab/jmartinalbo/${PRODNUM}.${SLURM_ARRAY_TASK_ID}.config.mac"

echo "/PhysicsList/RegisterPhysics G4EmStandardPhysics_option4" >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4DecayPhysics"              >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4RadioactiveDecayPhysics"   >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4OpticalPhysics"            >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics NexusPhysics"                >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4StepLimiterPhysics"        >> ${INI_MACRO}
echo "/Geometry/RegisterGeometry      NEXT100_OPT"              >> ${INI_MACRO}
echo "/Generator/RegisterGenerator    DECAY0"                   >> ${INI_MACRO}
echo "/Actions/RegisterRunAction      DEFAULT"                  >> ${INI_MACRO}
echo "/Actions/RegisterEventAction    DEFAULT"                  >> ${INI_MACRO}
echo "/Actions/RegisterTrackingAction DEFAULT"                  >> ${INI_MACRO}
echo "/nexus/RegisterMacro ${CFG_MACRO}"                        >> ${INI_MACRO}
echo " "                                                        >> ${INI_MACRO}

echo "/run/verbose 0"                                           >> ${CFG_MACRO}
echo "/event/verbose 0"                                         >> ${CFG_MACRO}
echo "/tracking/verbose 0"                                      >> ${CFG_MACRO}
echo "/process/optical/processActivation Cerenkov false"        >> ${CFG_MACRO}
echo "/Generator/Decay0Interface/inputFile none"                >> ${CFG_MACRO}
echo "/Generator/Decay0Interface/Xe136DecayMode 1"              >> ${CFG_MACRO}
echo "/Generator/Decay0Interface/Ba136FinalState 0"             >> ${CFG_MACRO}
echo "/Generator/Decay0Interface/region ACTIVE"                 >> ${CFG_MACRO}
echo "/Geometry/Next100/pressure 15.0 bar"                      >> ${CFG_MACRO}
echo "/Geometry/Next100/sc_yield 25510. 1/MeV"                  >> ${CFG_MACRO}
echo "/Geometry/Next100/EL_field 16. kilovolt/cm"               >> ${CFG_MACRO}
echo "/Geometry/Next100/drift_transv_diff 1.0 mm/sqrt(cm)"      >> ${CFG_MACRO}
echo "/Geometry/Next100/drift_long_diff   0.2 mm/sqrt(cm)"      >> ${CFG_MACRO}
echo "/Geometry/Next100/e_lifetime 12.0 ms"                     >> ${CFG_MACRO}
echo "/Geometry/Next100/elfield true"                           >> ${CFG_MACRO}
echo "/Geometry/Next100/max_step_size 1. mm"                    >> ${CFG_MACRO}
echo "/Geometry/Next100/sipm_time_binning 1. microsecond"       >> ${CFG_MACRO}
echo "/Geometry/PmtR11410/time_binning 25. nanosecond"          >> ${CFG_MACRO}
echo "/Geometry/PmtR11410/SD_depth 3"                           >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/clustering true"                       >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/drift true"                            >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/electroluminescence true"              >> ${CFG_MACRO}
echo "/nexus/random_seed ${RNDSEED}"                            >> ${CFG_MACRO}
echo "/nexus/persistency/start_id ${STARTID}"                   >> ${CFG_MACRO}
echo "/nexus/persistency/outputFile ${OUTFILE}"                 >> ${CFG_MACRO}
echo " "                                                        >> ${CFG_MACRO}

time /n/holystore01/LABS/guenette_lab/Lab/software/next/nexus/nexus-v6_00_00/build/source/nexus -b -n ${NEVENTS} ${INI_MACRO} 
cp "${OUTFILE}.h5" /n/holystore01/LABS/guenette_lab/Lab/data/NEXT/NEXT100/sim/0nubb/${PRODNUM}/nexus
