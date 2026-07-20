#!/bin/sh

echo
echo ===== Map warnings =====
grep "^Warning (" output_files/*.map.rpt > output_files/map_warnings.txt
diff -s checks/expected_map_warnings.txt output_files/map_warnings.txt

echo
echo ===== Fit warnings =====
grep "^Warning (" output_files/*.fit.rpt > output_files/fit_warnings.txt
diff -s checks/expected_fit_warnings.txt output_files/fit_warnings.txt

echo
echo ===== STA warnings =====
grep "^Warning (" output_files/*.sta.rpt > output_files/sta_warnings.txt
diff -s checks/expected_sta_warnings.txt output_files/sta_warnings.txt

echo
echo ===== Done =====
