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
NEVENTS=2000000
STARTID=$(((RNDSEED-1)*NEVENTS))
OUTFILE="/n/holyscratch01/guenette_lab/new.th_dep.nexus.${SLURM_ARRAY_TASK_ID}"

## Configure scisoft software products
. /n/holylfs02/LABS/guenette_lab/software/next/scisoft/setup
setup hdf5   v1_10_5     -q e19
setup root   v6_18_04    -q e19:prof

# Configure Geant4 and GATE
. /n/holylfs02/LABS/guenette_lab/users/jmartinalbo/extsw/geant4/10.02.p03/bin/geant4.sh
export GATE_DIR=/data4/NEXT/sw/Releases/NEXT_v1_04_00/sources/GATE
export LD_LIBRARY_PATH=${GATE_DIR}/lib:${LD_LIBRARY_PATH}

## Generate nexus macros
INI_MACRO="/n/holyscratch01/guenette_lab/nexus.init.${SLURM_ARRAY_TASK_ID}.mac"
CFG_MACRO="/n/holyscratch01/guenette_lab/nexus.config.${SLURM_ARRAY_TASK_ID}.mac"

echo "/PhysicsList/RegisterPhysics G4EmStandardPhysics_option4" >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4DecayPhysics"              >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4RadioactiveDecayPhysics"   >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics NexusPhysics"                >> ${INI_MACRO}
echo "/PhysicsList/RegisterPhysics G4StepLimiterPhysics"        >> ${INI_MACRO}
echo "/Geometry/RegisterGeometry NEXT_NEW"                      >> ${INI_MACRO}
echo "/Generator/RegisterGenerator ION_GUN"                     >> ${INI_MACRO}
echo "/Actions/RegisterRunAction DEFAULT"                       >> ${INI_MACRO}
echo "/Actions/RegisterEventAction DEFAULT"                     >> ${INI_MACRO}
echo "/Actions/RegisterTrackingAction DEFAULT"                  >> ${INI_MACRO}
echo "/nexus/RegisterMacro ${CFG_MACRO}"                        >> ${INI_MACRO}
echo " "                                                        >> ${INI_MACRO}

echo "/run/verbose      1"                                      >> ${CFG_MACRO}
echo "/event/verbose    0"                                      >> ${CFG_MACRO}
echo "/tracking/verbose 0"                                      >> ${CFG_MACRO}
echo "/Generator/IonGun/region INTERNAL_PORT_UPPER"             >> ${CFG_MACRO}
echo "/Generator/IonGun/atomic_number 81"                       >> ${CFG_MACRO}
echo "/Generator/IonGun/mass_number 208"                        >> ${CFG_MACRO}
echo "/Geometry/NextNew/pressure 10.2 bar"                      >> ${CFG_MACRO}
echo "/Geometry/NextNew/elfield false"                          >> ${CFG_MACRO}
echo "/Geometry/CalibrationSource/source Th"                    >> ${CFG_MACRO}
echo "/Geometry/NextNew/internal_calib_port upper"              >> ${CFG_MACRO}
echo "/Geometry/NextNew/source_distance 0. mm"                  >> ${CFG_MACRO}
echo "/Geometry/NextNew/max_step_size 10. m"                    >> ${CFG_MACRO}
echo "/Geometry/PmtR11410/SD_depth 4"                           >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/clustering false"                      >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/drift false"                           >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/electroluminescence false"             >> ${CFG_MACRO}
echo "/Actions/DefaultEventAction/energy_threshold 1.4 MeV"     >> ${CFG_MACRO}
echo "/Actions/DefaultEventAction/max_energy 1.8 MeV"           >> ${CFG_MACRO}
echo "/nexus/random_seed ${RNDSEED}"                            >> ${CFG_MACRO}
echo "/nexus/persistency/hdf5 false"                            >> ${CFG_MACRO}
echo "/nexus/persistency/start_id ${STARTID}"                   >> ${CFG_MACRO}
echo "/nexus/persistency/outputFile ${OUTFILE}"                 >> ${CFG_MACRO}
echo " "                                                        >> ${CFG_MACRO}

/n/holylfs02/LABS/guenette_lab/users/jmartinalbo/nexus-v5_03_07/nexus -b -n ${NEVENTS} ${INI_MACRO}
cp "${OUTFILE}.h5" /n/holylfs02/LABS/guenette_lab/data/NEXT
