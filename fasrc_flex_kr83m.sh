#!/bin/bash

#SBATCH -J nexus        # A single job name for the array
#SBATCH -n 1            # Number of cores
#SBATCH -N 1            # All cores on one machine
#SBATCH -p guenette     # Partition
#SBATCH --mem 1000      # Memory request (Mb)
#SBATCH -t 0-24:00      # Maximum execution time (D-HH:MM)
#SBATCH -o %A_%a.out    # Standard output
#SBATCH -e %A_%a.err    # Standard error

## Job options
RNDSEED=$(( SLURM_ARRAY_TASK_ID+1 ))
PRODNUM=99999999
NEVENTS=1000
STARTID=$(( SLURM_ARRAY_TASK_ID*NEVENTS ))
OUTFILE="/n/holyscratch01/guenette_lab/jmartinalbo/flex.kr83m.${SLURM_ARRAY_TASK_ID}.nexus"

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

echo "/Geometry/RegisterGeometry      NEXT_FLEX"                >> ${INI_MACRO}
echo "/Generator/RegisterGenerator Kr83m"                       >> ${INI_MACRO}

echo "/Actions/RegisterRunAction      DEFAULT"                  >> ${INI_MACRO}
echo "/Actions/RegisterEventAction    DEFAULT"                  >> ${INI_MACRO}
echo "/Actions/RegisterTrackingAction DEFAULT"                  >> ${INI_MACRO}
echo "/nexus/RegisterMacro ${CFG_MACRO}"                        >> ${INI_MACRO}
echo " "                                                        >> ${INI_MACRO}

echo "/Geometry/NextFlex/gas              enrichedXe"           >> ${CFG_MACRO}
echo "/Geometry/NextFlex/gas_pressure     15.   bar"            >> ${CFG_MACRO}
echo "/Geometry/NextFlex/gas_temperature  300.  kelvin"         >> ${CFG_MACRO}
echo "/Geometry/NextFlex/e_lifetime       12. ms"               >> ${CFG_MACRO}

echo "/Geometry/NextFlex/active_length      1204.95 mm"         >> ${CFG_MACRO}
echo "/Geometry/NextFlex/drift_transv_diff  1.0 mm/sqrt(cm)"    >> ${CFG_MACRO}
echo "/Geometry/NextFlex/drift_long_diff    0.2 mm/sqrt(cm)"    >> ${CFG_MACRO}

echo "/Geometry/NextFlex/buffer_length    254.6 mm"             >> ${CFG_MACRO}

echo "/Geometry/NextFlex/cathode_transparency .98"              >> ${CFG_MACRO}
echo "/Geometry/NextFlex/anode_transparency   .88"              >> ${CFG_MACRO}
echo "/Geometry/NextFlex/gate_transparency    .88"              >> ${CFG_MACRO}

echo "/Geometry/NextFlex/el_gap_length    10.  mm"              >> ${CFG_MACRO}
echo "/Geometry/NextFlex/el_field_on      true"                 >> ${CFG_MACRO}
echo "/Geometry/NextFlex/el_field_int     16. kilovolt/cm"      >> ${CFG_MACRO}
echo "/Geometry/NextFlex/el_transv_diff   0. mm/sqrt(cm)"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/el_long_diff     0. mm/sqrt(cm)"       >> ${CFG_MACRO}

echo "/Geometry/NextFlex/fc_wls_mat       TPB"                  >> ${CFG_MACRO}

echo "/Geometry/NextFlex/fc_with_fibers   false"                >> ${CFG_MACRO}
echo "/Geometry/NextFlex/fiber_mat        EJ280"                >> ${CFG_MACRO}
echo "/Geometry/NextFlex/fiber_claddings  2"                    >> ${CFG_MACRO}

echo "/Geometry/NextFlex/fiber_sensor_time_binning  25. ns"     >> ${CFG_MACRO}

echo "/Geometry/NextFlex/ep_with_PMTs         true"             >> ${CFG_MACRO}
echo "/Geometry/NextFlex/ep_with_teflon       false"            >> ${CFG_MACRO}
echo "/Geometry/NextFlex/ep_copper_thickness  12. cm"           >> ${CFG_MACRO}
echo "/Geometry/NextFlex/ep_wls_mat           TPB"              >> ${CFG_MACRO}

echo "/Geometry/PmtR11410/SD_depth            3"                >> ${CFG_MACRO}
echo "/Geometry/PmtR11410/time_binning        25. ns"           >> ${CFG_MACRO}

echo "/Geometry/NextFlex/tp_copper_thickness   12.    cm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_teflon_thickness    2.1   mm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_teflon_hole_diam    7.    mm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_wls_mat            TPB"             >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_sipm_anode_dist    13.1   mm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_sipm_sizeX         1.3    mm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_sipm_sizeY         1.3    mm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_sipm_pitchX        15.55  mm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_sipm_pitchY        15.55  mm"       >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_sipm_time_binning  1. microsecond"  >> ${CFG_MACRO}

echo "/Geometry/NextFlex/ics_thickness  12. cm"                 >> ${CFG_MACRO}

echo "/Geometry/NextFlex/verbosity     true"                    >> ${CFG_MACRO}
echo "/Geometry/NextFlex/fc_verbosity  true"                    >> ${CFG_MACRO}
echo "/Geometry/NextFlex/ep_verbosity  true"                    >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_verbosity  true"                    >> ${CFG_MACRO}

echo "/Geometry/NextFlex/fc_visibility  false"                  >> ${CFG_MACRO}
echo "/Geometry/NextFlex/ep_visibility  false"                  >> ${CFG_MACRO}
echo "/Geometry/NextFlex/tp_visibility  false"                  >> ${CFG_MACRO}
echo "/Geometry/NextFlex/ics_visibility false"                  >> ${CFG_MACRO}
echo "/Geometry/PmtR11410/visibility    false"                  >> ${CFG_MACRO}

echo "/Generator/Decay0Interface/inputFile none"                >> ${CFG_MACRO}
echo "/Generator/Decay0Interface/Xe136DecayMode 1"              >> ${CFG_MACRO}
echo "/Generator/Decay0Interface/Ba136FinalState 0"             >> ${CFG_MACRO}
echo "/Generator/Decay0Interface/region ACTIVE"                 >> ${CFG_MACRO}

echo "/process/optical/processActivation Cerenkov false"        >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/clustering           true"             >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/drift                true"             >> ${CFG_MACRO}
echo "/PhysicsList/Nexus/electroluminescence  true"             >> ${CFG_MACRO}

echo "/control/verbose   0"                                     >> ${CFG_MACRO}
echo "/run/verbose       0"                                     >> ${CFG_MACRO}
echo "/event/verbose     0"                                     >> ${CFG_MACRO}
echo "/tracking/verbose  0"                                     >> ${CFG_MACRO}

echo "/nexus/random_seed ${RNDSEED}"                            >> ${CFG_MACRO}
echo "/nexus/persistency/start_id ${STARTID}"                   >> ${CFG_MACRO}
echo "/nexus/persistency/outputFile ${OUTFILE}"                 >> ${CFG_MACRO}

time /n/holystore01/LABS/guenette_lab/Lab/software/next/nexus/nexus-flex.20200619/build/source/nexus -b -n ${NEVENTS} ${INI_MACRO}
cp "${OUTFILE}.h5" /n/holystore01/LABS/guenette_lab/Lab/data/NEXT/FLEX/kr83m/${PRODNUM}/nexus
