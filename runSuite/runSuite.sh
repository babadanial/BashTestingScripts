#!/bin/bash

# print usage message if wrong # of arguments
if [ ${#} -ne 2 ]; then
   echo Usage: ${0} suite_file program >&2
   exit 1
fi

# conducts tests
for filestem in $(cat "${1}"); do

   HASARGS=$((0))
   HASINPUT=$((0))

   ls -l | egrep "^.r.*${filestem}.out" > /dev/null
   if [ ${?} -ne 0 ]; then
      echo File does not exist or isn\'t readable >&2
      exit 1
   fi

   # checks if the corresponding .args file exists
   ls | egrep "${filestem}.args" > /dev/null
   if [ ${?} -eq 0 ]; then
      HASARGS=$((1)) # if HASARGS is 1, then the .args file exists
   fi

   # checks if the corresponding input file exists
   ls | egrep "${filestem}.in" > /dev/null
   if [ ${?} -eq 0 ]; then
      HASINPUT=$((1)) # if HASINPUT is 1, then the .in file exists
   fi

   # stores actual outputs in temporary file
   TMPFILE=$(mktemp /tmp/runSuite.XXX)
   if [ ${HASARGS} -eq 0 -a ${HASINPUT} -eq 0 ]; then
      ./${2} > $TMPFILE
   elif [ ${HASARGS} -eq 1 -a ${HASINPUT} -eq 0 ]; then
      ./${2} $(cat "${filestem}.args") > ${TMPFILE}
   elif [ ${HASARGS} -eq 0 -a ${HASINPUT} -eq 1 ]; then
      ./${2} < "${filestem}.in" > ${TMPFILE}
   else 
      ./${2} $(cat "${filestem}.args") < "${filestem}.in" > ${TMPFILE}
   fi 

   # produces outputs in case the test failed
   # actual outputs placed in temp file which is deleted after
   diff -q ${TMPFILE} ${filestem}.out > /dev/null
   if [ ${?} -ne 0 ]; then
      echo "Test failed: ${filestem}" 
      echo Args:
      if [ ${HASARGS} -eq 1 ]; then
         cat "${filestem}.args"
      fi
      echo Input:
      if [ ${HASINPUT} -eq 1 ]; then
         cat "${filestem}.in"
      fi
      echo Expected:
      cat "${filestem}.out"
      echo Actual:
      cat "${TMPFILE}"
      rm "${TMPFILE}"
   fi
done
