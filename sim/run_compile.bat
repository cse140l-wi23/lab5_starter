if exist ..\inst_mem.mif (
    copy /Y ..\inst_mem.mif .
)

if exist work rmdir /S /Q work

vlib work
REM vlog -nolock ../tb/*.v
REM if exist ../*.v (
REM	vlog -nolock ../*.v
REM )
if exist ../*.sv (
REM	vlog -sv -nolock ../tb/*.v ../tb/*.sv
	vlog -sv -nolock ../fifo.sv ../lfsr5.sv ../dat_mem.sv ../seqsm.sv ../lab5_dp.sv ../lab5.sv ../lab5_tb.sv 
)
REM if exist ../*.vhd (
REM	vcom -nolock ../*.vhd
REM )

