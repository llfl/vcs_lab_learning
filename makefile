all: com sim
.PHONY:update_file com sim clean

OUTPUT = adder_top

BUILDING_DIR = ./lab1/parta

ALL_DEFINE = +define+DUMP_VPD

#code coverage command
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name ${OUTPUT}
CM_DIR = -cm_dir ./${OUTPUT}.vdb
# CM_HIER = -cm_hier cov.cfg

VPD_NAME = +vpdfile+${OUTPUT}.vpd

VCS = vcs -sverilog +v2k -timescale=1ns/1ns                             \
	  -debug_all			\
	  -o ${OUTPUT}			\
	  -l compile.log		\
	  ${VPD_NAME}			\
	  ${ALL_DEFINE}			\
	  ${CM}					\
	  ${CM_NAME}			\
	  ${CM_DIR}				\
	  ${CM_HIER}			\
	  -debug_pp 			\
	  -Mupdate

SIM = ./${OUTPUT} -l run.log \
	  ${CM}					\
	  ${CM_NAME}				\
	  ${CM_DIR}				\
	  -l ${OUTPUT}.log

update_file: 
	find ${BUILDING_DIR} -name "*.sv" > file.list
	find ${BUILDING_DIR} -name "*.v" >> file.list

com: update_file
	${VCS} -f file.list

sim:
	${SIM}

#show the coverage
cov:
	dve -covdir *.vdb &

debug:
	dve -vpd ${OUTPUT}.vpd &

clean:
	rm -rf ./csrc *.daidir *.log simv* *.key file.list *.vpd ./DVEfiles ${OUTPUT} *.vdb