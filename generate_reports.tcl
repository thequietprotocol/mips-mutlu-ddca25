open_project lab9/lab_vivado/mipsUp_final.xpr
open_run impl_1

report_timing -setup -file reports/timing_setup.txt
report_timing -hold -file reports/timing_hold.txt
report_utilization -file reports/utilization_report.txt
report_clocks -file reports/clocks_report.txt
report_power -file reports/power_report.txt
report_io -file reports/io_report.txt

exit
