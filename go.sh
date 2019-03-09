# #! /bin/bash -e

cd /home/pi/pascal/ads1115_library/master

echo "#################"
echo "#### Compile ####"
echo "#################"
if /usr/local/codetyphon/typhon/bin32/typhonbuild ./ads1115_project.ctpr; then
  echo
  echo "#######################"
  echo "#### Start program ####"
  echo "#######################"
  ./ads1115_project
fi

read key
