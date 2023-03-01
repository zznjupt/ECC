vcs: com sim

com:
	vcs -full64 -sverilog -debug_all -timescale=1ns/10ps -f file.list -l com.log -fsdb +define+fsdb
sim:
	./simv -l sim.log

verdi:
	verdi -f file.list -ssf *.fsdb -nologo

clean:
	rm -rf *.log *key *.fsdb simv ./tb/csrc csrc simv.daidir