#!/bin/bash
# This is the produceOutputs file

# print usage message if wrong # of arguments
if [ ${#} -ne 2 ]; then
   echo Usage: ${0} suite_txt_file program >&2
   exit 1
fi 

# checking if file is readable
ls -l ${1} | egrep "^.r" > /dev/null
if [ ${?} -ne 0 ]; then
   echo Suite file unreadable >&2
   exit 1
fi

# checking if program is executable
ls -l ${2} | egrep "^...x" > /dev/null
if [ ${?} -ne 0 ]; then
   echo Program is not executable >&2
   exit 1
fi

# Creates expected output files, using arguments if they exist
for filestem in $(cat "${1}"); do

   HASINPUT=$((0))
   HASARGS=$((0))

   # determines if arguments file exists for the given test
   ls | egrep "${filestem}.args" > /dev/null
   if [ ${?} -eq 0 ]; then
      HASARGS=$((1))
   fi

   # determines if input file exists for the given test
   ls | egrep "${filestem}.in" > /dev/null
   if [ ${?} -eq 0 ]; then
      HASINPUT=$((1))
   fi

   # creates output files, with arguments and/or input if they are provided
   if [ ${HASINPUT} -eq 0 -a ${HASARGS} -eq 0 ]; then
      ./${2} > "${filestem}.out" 2> "${filestem}.err"
      echo ${?} > "${filestem}.exit"
   elif [ ${HASINPUT} -eq 0 -a ${HASARGS} -eq 1 ]; then
      ./${2} $(cat "${filestem}.args") > "${filestem}.out" 2> "${filestem}.err"
      echo ${?} > "${filestem}.exit"
   elif [ ${HASINPUT} -eq 1 -a ${HASARGS} -eq 0 ]; then
      ./${2} < "${filestem}.in" > "${filestem}.out" 2> "${filestem}.err"
      echo ${?} > "${filestem}.exit"
   else 
      ./${2} $(cat "${filestem}.args") < "${filestem}.in" > "${filestem}.out" 2> "${filestem}.err"
      echo ${?} > "${filestem}.exit"
   fi
done