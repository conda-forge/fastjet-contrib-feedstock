#!/bin/bash
set -x

# The repository is too large to vendor in the info/test/ package metadata, so download it
# Need to use PKG_VERSION as the shell script doesn't have access to Jinja2 variables
# c.f. https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#environment-variables-set-during-the-build-process
curl -sL https://fastjet.hepforge.org/contrib/downloads/fjcontrib-"${PKG_VERSION}".tar.gz | tar -xz
cd fjcontrib-"${PKG_VERSION}"

cd Centauro
grep -rl '#include "Centauro.hh"' | xargs sed -i 's|#include "Centauro.hh"|#include "fastjet/contrib/Centauro.hh"|g'
$CXX example.cc -o example $CXXFLAGS $LDFLAGS -lfastjetcontribfragile -lfastjettools -lfastjet
./example < ../data/single-event.dat &> Centauro_example_output.txt || ./example < ../data/single-event.dat

cd ../ClusteringVetoPlugin
grep -rl '#include "ClusteringVetoPlugin.hh"' | xargs sed -i 's|#include "ClusteringVetoPlugin.hh"|#include "fastjet/contrib/ClusteringVetoPlugin.hh"|g'
$CXX example.cc -o example $CXXFLAGS $LDFLAGS -lfastjetcontribfragile -lfastjettools -lfastjet
./example < ../data/single-event.dat &> ClusteringVetoPlugin_example_output.txt

cd ../ConstituentSubtractor
grep -rl '#include "ConstituentSubtractor.hh"' | xargs sed -i 's|#include "ConstituentSubtractor.hh"|#include "fastjet/contrib/ConstituentSubtractor.hh"|g'
grep -rl '#include "IterativeConstituentSubtractor.hh"' | xargs sed -i 's|#include "IterativeConstituentSubtractor.hh"|#include "fastjet/contrib/IterativeConstituentSubtractor.hh"|g'
grep -rl '#include "RescalingClasses.hh"' | xargs sed -i 's|#include "RescalingClasses.hh"|#include "fastjet/contrib/RescalingClasses.hh"|g'
$CXX example_jet_by_jet.cc -o example_jet_by_jet $CXXFLAGS $LDFLAGS -lfastjetcontribfragile -lfastjettools -lfastjet
./example_jet_by_jet < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_jet_by_jet_output.txt
$CXX example_event_wide.cc -o example_event_wide $CXXFLAGS $LDFLAGS -lfastjetcontribfragile -lfastjettools -lfastjet
./example_event_wide < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_event_wide_output.txt
$CXX example_iterative.cc -o example_iterative $CXXFLAGS $LDFLAGS -lfastjetcontribfragile -lfastjettools -lfastjet
./example_iterative < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_iterative_output.txt
$CXX example_background_rescaling.cc -o example_background_rescaling $CXXFLAGS $LDFLAGS -lfastjetcontribfragile -lfastjettools -lfastjet
./example_background_rescaling < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_background_rescaling_output.txt
$CXX example_whole_event_using_charged_info.cc -o example_whole_event_using_charged_info $CXXFLAGS $LDFLAGS -lfastjetcontribfragile -lfastjettools -lfastjet
./example_whole_event_using_charged_info < ../data/Pythia-Zp2jets-lhc-pileup-1ev.dat &> example_whole_event_using_charged_info_output.txt
