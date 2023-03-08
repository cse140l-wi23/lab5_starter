REM    vsim -pli simfpga.vpi -Lf 220model -Lf altera_mf_ver -Lf verilog -c -do "run -all" lab3_tb
if exist ../lab5_tb.sv (
   vsim -c -do "run -all" lab5_tb
)

