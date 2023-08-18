#!/bin/bash -l

source ../base/const.sh
source ../base/vrun_launcher.sh

#PUT compiler source stuff here
source ${COMPILER_ROOT}/compilers/intel/19.0/Linux/intel64/load0.sh

parameter_set_decoding () {
	codelet=$1
	datasize=$2
	repetition=$3
	rundir=$4

	# Create the datasize file for codelet run
	echo "${repetition} ${datasize}" > ./codelet.data
	echo -e "arraysize\n${datasize}" > arguments.csv
	echo ""
}

build_codelet () {
	codelet_folder="$1"
	codelet_name="$2"
	build_folder="$3"

	# Simple codelet compilation
	binary_name=$( grep "binary name" "$codelet_folder/codelet.conf" | sed -e 's/.*"\(.*\)".*/\1/g' )
	echo -e "Binary name \t'$binary_name'"
	# ensured it is at the same level as codelet_folder so that relative paths in Makefile is preserved it will be moved to the build_folder
	# after generating original
	build_tmp_folder=$(mktemp -d --tmpdir=${codelet_folder}/..)


	echo "Generating codelet '$codelet_folder/$codelet_name'..."

	echo "Compiler information using -v flags"
	ifort -v
	icc -v
	icpc -v

	build_files=$(find ${codelet_folder} -maxdepth 1 -type f -o -type l)
	cp ${build_files} ${build_tmp_folder}

	cd ${build_tmp_folder}

	if [[ "$ENABLE_SEP" == "1" ]]; then
		make clean ENABLE_SEP=sep ${emon_api_flags} all
	else
		# if [[ "$ACTIVATE_EMON_API" == "1" ]]
		# then
		# 	if [[ "$(uname)" == "CYGWIN_NT-6.2" ]]; then
		# 	    make clean LIBS="measure_emon_api_dca.lib prog_api.lib" LIBPATH="-LIBPATH:../../../../../cape-common/lib -LIBPATH:z:/software/DCA/EMON_DCA_engineering_build_v01/lib64" all
		# 	else
		# 	    make clean LIBS="-lmeasure_emon_api -lprog_api -L/opt/intel/sep/bin64" LIBPATH="${PROBE_FOLDER}" all
		# 	fi
		# 	if [[ "$?" != "0" ]]
		# 	    then
		# 	    echo "ERROR! Make did not succeed in creating EMON API instrumented codelet."
		# 	    exit -1
		# 	fi
		# 	mv "$binary_name" "$codelet_name"_emon_api
		# 	cp "$codelet_name"_emon_api "$codelet_folder/$CLS_RES_FOLDER/$BINARIES_FOLDER"
		# fi
		# The above build steps would be outdated but preserve for reference (esp. for windows verions)
		make LIBPATH="${BASE_PROBE_FOLDER}" clean all
	fi

	# &> /dev/null
	res=$?

	if [[ "$res" != "0" ]]; then
		echo "ERROR! Make did not succeed."
		exit -1
	fi

	mv "$binary_name" "$codelet_name"
	res=$?

	if [[ "$res" != "0" ]]; then
		echo "ERROR! Move did not succeed."
		exit -1
	fi


	if [[ -e "codelet.o" ]]; then
		cp "codelet.o" "$codelet_folder/$CLS_RES_FOLDER/"
	fi

	# Should be safe because $binary_name was already renamed to $codelet_name
	make clean &> /dev/null

	echo "Codelet generation was successful."
	mv ${build_tmp_folder} "${build_folder}"
}

export -f parameter_set_decoding
export -f build_codelet

run() {
	runId=$@

	#variants="REF LS FP DL1 NOLS-NOFP FP_SAN REF_SAN FES LS_FES FP_FES"
	variants="REF LS FP DL1 FES"
	#variants="REF LS FP"
	#variants="REF"
	variants="ORG"
	#variants="REF_SAN"
	#variants="FP"
	#variants="LS"
	#linear_sizes="2000 10000000"
	#linear_sizes="1000 2000"

	#linear_sizes="1000 2000 4000 6000 8000 10000 20000 40000 60000 80000 100000 200000 400000 600000 800000 1000000 2000000 4000000 6000000 8000000 10000000"

	#linear_sizes="2000 8000 80000 200000 600000 1000000"
	#linear_sizes="2000 10000 400000 8000000"
	#linear_sizes="2000 8000 400000"
	# Even small datasizes for LDA code (like svd11)
	#linear_sizes="600 800 1000"
	#linear_sizes="1000"
	#linear_sizes="400 2000 10000"
	#linear_clda_sizes="1000 10000"
	linear_clda_sizes="1000"
	#ubmk_sizes="400 2000 10000 800000"
	#ubmk_sizes="10000 800000"
	#ubmk_sizes="800000"
	#ubmk_sizes="100 200 400 600 800 1000 2000 4000 6000 8000 10000 20000 40000 60000 80000 100000 200000"
	#ubmk_sizes="600 1000"
	#ubmk_sizes="200 1000 10000"
	#ubmk_sizes="10000"
	ubmk_sizes="100000 200000"

	#linear_sizes="400000"
	#linear_sizes="200000 400000 600000 800000"
	#linear_sizes="2000 10000"
	#linear_sizes="1000 10000"
	#linear_sizes="10000"
	# Will check size problem below for hqr13 and toe3
	#linear_sizes="100 1000 10000 400000"
	#linear_sizes="3000 4000 5000"
	#linear_sizes="1000 10000 400000"


	#linear_sizes="800000"
	#linear_sizes="100 200 400 600 800"
	#linear_sizes="1100 1200 1400 1600 1800"
	#linear_sizes="1000000 2000000 4000000 6000000 8000000 10000000"
	#linear_sizes="1000000 4000000 8000000 10000000"
	#linear_sizes="1000 2000 4000 8000 20000  60000 100000  400000 800000 1000000  10000000"
	#linear_sizes="100000  400000 800000 1000000  10000000"
	#linear_sizes="1000 2000 1000000  10000000"
	#linear_sizes="2000 100000 1000000  10000000"
	#linear_sizes="208 240 304 352 400 528 608 704 800 928 1008 1100 1200 1300 1400 1500 1600 1800 2000 2500 3000"
	# for ubmk branch_de
	#linear_sizes="48 104 208 304 328 344 352 360 368 376 384 392 400 432 456 504 600 800 1440 2000 3000 30000"

	#linear_sizes="6 13"
	#linear_sizes="6 13 26 38 41 43 44 45 46 47 48 49 50 54 57 63 75 100 180 250 375 3750"


	#linear_sizes="1000 2000 4000 6000 8000 10000 20000 40000"
	linear_sizes="10000"

        # Lore codelet size.
	lore_sizes="10000"

	#quadratic_sizes="208 240 304 352 400 528 608 704 800 928 1008 1100 1200 1300 1400 1500 1600 1800 2000 2500 3000"
	#quadratic_sizes="800"
	#quadratic_sizes="1500 3000 6000"
	#quadratic_sizes="208 304 528  1500 3000"
	#quadratic_sizes="208 352 608 928 1200 1500 2000 3000"
	#quadratic_sizes="208 352 608 928 1300 2500"
	#quadratic_sizes="208 240 400 2500 3000"
	quadratic_sizes="100"
	#quadratic_sizes="928 1008 1100"
	#quadratic_sizes="928"
	#quadratic_sizes="10 30 100 400 630 928"
	#quadratic_sizes="100 400"
	# try to follow Hafid's sizes
	#quadratic_sizes="100 208 240 352 400 528"
	#quadratic_sizes="100"
	#quadratic_sizes="10 30 100 400"
	#quadratic_sizes="208 400 528"

	#quadratic_sizes="400 2500"
	#quadratic_sizes="3000"
	#memory_loads="0 99999"
	memory_loads="0"
	#num_cores="2 4 8"
	#num_cores="1 2 4 8"
	#num_cores="1 8"
	#num_cores="2 4"
	#num_cores="1 2 8"
	#num_cores="1 2"
	num_cores="1"
	#num_cores="4"
	#num_cores="2 4"
	prefetchers="0"
	#prefetchers="0 15"
	#prefetchers="15"
	#frequencies="1200000 2800000"
	#frequencies="2800000"
	frequencies="2400000"
	frequencies="3500000"
	#frequencies="1200000 2000000 2800000"
	#frequencies="1200000 1300000 1400000 1500000 1700000 1800000 1900000 2000000 2100000 2200000 2300000 2500000 2600000 2700000 2800000"
	#frequencies="1200000"

	linear_codelets=""
	quadratic_codelets=""
	ptr_codelets=""


	#prefix="/nfs/fx/home/cwong29/working/NR-scripts"
	prefix=$(readlink -f ../..)
	#ubmkprefix="${prefix}/nr-codelets/bws/nr_ubmks"
	ubmkprefix="${prefix}/nr-codelets/bws"
	nr_prefix="${prefix}/nr-codelets/numerical_recipes/Fortran"
	saeed_prefix="${prefix}/intel_codelets"
	andy_prefix="${prefix}/andy_codelets/invitro"
	galois_prefix="${prefix}/galois_codelets"

	lin_s1_prefix="${nr_prefix}/1D_loop-Stride_1"
	lin_slda_prefix="${nr_prefix}/1D_loop-Stride_LDA"
	lin_sclda_prefix="${nr_prefix}/1D_loop-Stride_CLDA"
	quad_s1_prefix="${nr_prefix}/2D_loop-Stride_1"
	quad_slda_prefix="${nr_prefix}/2D_loop-Stride_LDA"
	quadt_s1_prefix="${nr_prefix}/2DT_loop-Stride_1"

	saeed_lin_s1_prefix="${saeed_prefix}/1D_loop-Stride_1"
	andy_lin_s1_prefix="${andy_prefix}/1D_loop-Stride_1"
	andy_quad_s1_prefix="${andy_prefix}/2D_loop-Stride_1"
	galois_lonestar_prefix="${galois_prefix}/lonestar"

	amarin_lore_prefix="${prefix}/compiler-evaluation-experiments/LoopGen/lore/"


	#linear_codelets="${ubmkprefix}/*"

	#linear_codelets+=" ${ubmkprefix}/balanc_3_1_ubmk_de"
	#linear_codelets+=" ${ubmkprefix}/balanc_3_1_ubmk_stonly_de"
	#linear_codelets+=" ${ubmkprefix}/s319_ls_se"
	#linear_codelets+=" ${ubmkprefix}/s319_st_only_se"
	#linear_codelets+=" ${ubmkprefix}/s319_st_1sonly_se"
	#linear_codelets+=" ${ubmkprefix}/s319_ld_1sonly_se"
	#linear_codelets+=" ${ubmkprefix}/s319_ld_bigstride_1sonly_se"


	#linear_codelets+=" ${ubmkprefix}/s319_st_bigstride_1sonly_se"

	#linear_codelets+=" ${ubmkprefix}/s319_ldst_1sonly_se"
	#linear_codelets+=" ${ubmkprefix}/s319_ldst_no_pxor_1sonly_se"
	#linear_codelets+=" ${ubmkprefix}/s319_se"
	#linear_codelets+=" ${ubmkprefix}/mprove_9_ubmk_de"

	#linear_codelets+=" ${saeed_lin_s1_prefix}/s319/s319_se"
	#linear_codelets+=" ${saeed_lin_s1_prefix}/s1244/s1244_se"


	#linear_codelets+=" ${ubmkprefix}/tridag_2r_de"
	#linear_codelets+=" ${ubmkprefix}/tridag_2r_1a_de"
	#linear_codelets+=" ${ubmkprefix}/tridag_2r_1a_1_de"
	#ptr_codelets+=" ${ubmkprefix}/ptr_ld_branch"

	#linear_codelets+=" ${ubmkprefix}/svdcmp_14_ubmk_de"
	#linear_codelets+=" ${ubmkprefix}/svdcmp_14_break_ubmk_de"
	#linear_codelets+=" ${ubmkprefix}/svdcmp_14_rename_ubmk_de"
	#linear_codelets+=" ${ubmkprefix}/svdcmp_14_loopinv_ubmk_de"
	#linear_codelets+=" ${ubmkprefix}/svdcmp_14_rename1_ubmk_de"
	#linear_codelets+=" ${ubmkprefix}/branch_de"
	#quadratic_codelets+=" ${ubmkprefix}/rstrct_29_simplified_de"


	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_wo_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro1r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro2r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro3r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro5r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro6r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro7r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro8r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro9r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro10r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro11r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro12r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro24r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_ro36r_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_wo1w_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_wo4w_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_dx"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_mulsd_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_mulmovsd_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_2mulmovsd_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_3mulmovsd_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_4mulmovsd_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_sU1_sVS_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_sU4_sVS_de"
	#linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_sU4_sVS_Svec_de"
	#linear_codelets+=" ${lin_s1_prefix}/elmhes_10/elmhes_10_de"
	#linear_codelets+=" ${lin_s1_prefix}/elmhes_10/elmhes_10_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/elmhes_10/elmhes_10_dx"
	#linear_codelets+=" ${lin_s1_prefix}/four1_2/four1_2_me"
	#linear_codelets+=" ${lin_s1_prefix}/four1_2/four1_2_ro_me"
	#linear_codelets+=" ${lin_s1_prefix}/four1_2/four1_2_mx"
	# bugged
	#linear_codelets+=" ${lin_s1_prefix}/hqr_13/hqr_13_de"
	#linear_codelets+=" ${lin_s1_prefix}/mprove_9/mprove_9_de"

	#linear_codelets+=" ${lin_s1_prefix}/realft_4/realft_4_de"
	#linear_codelets+=" ${lin_s1_prefix}/realft_4/realft_4_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/realft_4/realft_4_dx"
	#linear_codelets+=" ${lin_s1_prefix}/svdcmp_13/svdcmp_13_de"
	#linear_codelets+=" ${lin_s1_prefix}/svdcmp_14/svdcmp_14_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_1/toeplz_1_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_1/toeplz_1_sU1_sVS_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_2/toeplz_2_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_3/toeplz_3_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_4/toeplz_4_de"
	#linear_codelets+=" ${lin_s1_prefix}/tridag_1/tridag_1_de"
	#linear_codelets+=" ${lin_s1_prefix}/tridag_2/tridag_2_de"

	# more RO ones
	#linear_codelets+=" ${lin_s1_prefix}/mprove_9/mprove_9_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/svdcmp_13/svdcmp_13_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/svdcmp_14/svdcmp_14_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_2/toeplz_2_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_3/toeplz_3_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/toeplz_4/toeplz_4_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/tridag_1/tridag_1_ro_de"
	#linear_codelets+=" ${lin_s1_prefix}/tridag_2/tridag_2_ro_de"

	#linear_codelets+=" ${saeed_lin_s1_prefix}/s319/s319_ro_se"
	#linear_codelets+=" ${saeed_lin_s1_prefix}/s1244/s1244_ro_se"



	#linear_codelets+=" ${lin_sclda_prefix}/elmhes_11/elmhes_11_de"
	#linear_codelets+=" ${lin_sclda_prefix}/elmhes_11/elmhes_11_ro_de"
	#linear_codelets+=" ${lin_sclda_prefix}/svdcmp_6/svdcmp_6_de"
	#linear_codelets+=" ${lin_sclda_prefix}/svdcmp_11/svdcmp_11_de"
	#linear_codelets+=" ${lin_sclda_prefix}/svdcmp_11/svdcmp_11_ro_de"
	#linear_codelets+=" ${lin_sclda_prefix}/elmhes_11/elmhes_11_dx"
	#linear_codelets+=" ${lin_sclda_prefix}/svdcmp_6/svdcmp_6_dx"
	#linear_codelets+=" ${lin_sclda_prefix}/svdcmp_11/svdcmp_11_dx"



	#linear_codelets+=" ${lin_slda_prefix}/hqr_15/hqr_15_se"

	# more RO ones
	# somehow broken - need to fix script.
	#linear_codelets+=" ${lin_slda_prefix}/hqr_15/hqr_15_ro_se"



	#quadratic_codelets+=" ${quad_s1_prefix}/hqr_12sq/hqr_12sq_se"
	#quadratic_codelets+=" ${quad_s1_prefix}/matadd_16/matadd_16_de"
	#quadratic_codelets+=" ${quad_s1_prefix}/matadd_16/matadd_16_sU1_sVS_dx"
	#quadratic_codelets+=" ${quad_s1_prefix}/matadd_16/matadd_16_sVS_dx"
	#quadratic_codelets+=" ${quad_s1_prefix}/matadd_16/matadd_16_sU1_sVS_de"
	#quadratic_codelets+=" ${quad_s1_prefix}/matadd_16/matadd_16_sU1_sVS_de"
	#quadratic_codelets+=" ${quad_s1_prefix}/matadd_16/matadd_16_sVS_de"
	#quadratic_codelets+=" ${quad_s1_prefix}/mprove_8/mprove_8_me"
	#quadratic_codelets+=" ${quad_s1_prefix}/mprove_8/mprove_8_mx"
	#quadratic_codelets+=" ${quad_s1_prefix}/svbksb_3/svbksb_3_se"
	#quadratic_codelets+=" ${quad_s1_prefix}/svbksb_3/svbksb_3_sU1_sVS_se"
	#quadratic_codelets+=" ${quad_s1_prefix}/svbksb_3/svbksb_3_sVS_se"
	#quadratic_codelets+=" ${quad_s1_prefix}/svbksb_3/svbksb_3_sU1_sVS_sx"
	#quadratic_codelets+=" ${quad_s1_prefix}/svbksb_3/svbksb_3_sVS_sx"

	# more RO ones
	#quadratic_codelets+=" ${quad_s1_prefix}/matadd_16/matadd_16_ro_de"
	#quadratic_codelets+=" ${quad_s1_prefix}/mprove_8/mprove_8_ro_me"
	#quadratic_codelets+=" ${quad_s1_prefix}/svbksb_3/svbksb_3_ro_se"


	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13s_de"

	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13_dx"
	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13_sU1_sVS_dx"
	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13_sVS_dx"
	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13_sU1_sVS_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13_sVS_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/relax2_26/relax2_26_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/rstrct_29/rstrct_29_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/rstrct_29/rstrct_29_sU1_sVS_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/rstrct_29/rstrct_29_sVS_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/rstrct_29/rstrct_29_sU1_sVS_dx"
	#quadratic_codelets+=" ${quad_slda_prefix}/rstrct_29/rstrct_29_sVS_dx"

	# more RO ones
	#quadratic_codelets+=" ${quad_slda_prefix}/lop_13/lop_13_ro_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/relax2_26/relax2_26_ro_de"
	#quadratic_codelets+=" ${quad_slda_prefix}/rstrct_29/rstrct_29_ro_de"


	#quadratic_codelets+=" ${quadt_s1_prefix}/hqr_12/hqr_12_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/hqr_12/hqr_12_sU1_sVS_sx"
	#quadratic_codelets+=" ${quadt_s1_prefix}/hqr_12/hqr_12_sVS_sx"
	#quadratic_codelets+=" ${quadt_s1_prefix}/hqr_12/hqr_12_sU1_sVS_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/hqr_12/hqr_12_sVS_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/ludcmp_4/ludcmp_4_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/ludcmp_4/ludcmp_4_sU1_sVS_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/ludcmp_4/ludcmp_4_sVS_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/ludcmp_4/ludcmp_4_sU1_sVS_sx"
	#quadratic_codelets+=" ${quadt_s1_prefix}/ludcmp_4/ludcmp_4_sVS_sx"


	# more RO ones
	#quadratic_codelets+=" ${quadt_s1_prefix}/ludcmp_4/ludcmp_4_ro_se"


	# Should never run jacobi again (duplicated code)
	#quadratic_codelets+=" ${quadt_s1_prefix}/jacobi_5/jacobi_5_sU1_sVS_sx"
	#quadratic_codelets+=" ${quadt_s1_prefix}/jacobi_5/jacobi_5_sVS_sx"
	#quadratic_codelets+=" ${quadt_s1_prefix}/jacobi_5/jacobi_5_sU1_sVS_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/jacobi_5/jacobi_5_sVS_se"
	#quadratic_codelets+=" ${quadt_s1_prefix}/jacobi_5/jacobi_5_se"
	# Skip 2D loops for now.
	#quadratic_codelets=""


	# SR runs (including some original)
	declare -gA name2path
	declare -gA name2sizes
	declare -ga run_codelets


	# lin_s1_codelets=(
	#     "balanc_3/balanc_3_de" "balanc_3/balanc_3_sVS_de"
	#     "balanc_3/balanc_3_ro_de" "balanc_3/balanc_3_ro_sVS_de"
	#     "balanc_3/balanc_3_sr_de" "balanc_3/balanc_3_sr_sVS_de"
	#     "elmhes_10/elmhes_10_sr_de" "elmhes_10/elmhes_10_sr_sVS_de"
	#     "four1_2/four1_2_sr_me"
	#     "hqr_13/hqr_13_de" "hqr_13/hqr_13_sVS_de"
	#     "mprove_9/mprove_9_sr_de" "mprove_9/mprove_9_sr_sVS_de"
	#     "realft_4/realft_4_sr_de"
	#     "svdcmp_13/svdcmp_13_sr_de" "svdcmp_13/svdcmp_13_sr_sVS_de"
	#     "svdcmp_14/svdcmp_14_sr_de" "svdcmp_14/svdcmp_14_sr_sVS_de"
	#     "toeplz_1/toeplz_1_de" "toeplz_1/toeplz_1_sVS_de"
	#     "toeplz_2/toeplz_2_sr_de"
	#     "toeplz_4/toeplz_4_sr_de"
	#     "tridag_1/tridag_1_sr_de"
	#     "tridag_2/tridag_2_sr_de"
	# )

	# saeed_lin_s1_codelets=(
	#     "s1244/s1244_sr_se" "s1244/s1244_sr_sVS_se"
	#     "s319/s319_sr_se" "s319/s319_sr_sVS_se"
	# )

	# lin_sclda_codelets=(
	#     "elmhes_11/elmhes_11_sr_de" "elmhes_11/elmhes_11_sr_sVS_de"
	#     "svdcmp_11/svdcmp_11_sr_de" "svdcmp_11/svdcmp_11_sr_sVS_de"
	#     "svdcmp_6/svdcmp_6_de" "svdcmp_6/svdcmp_6_sVS_de"
	# )

	# lin_slda_codelets=( "hqr_15/hqr_15_sr_se" )

	# quad_s1_codelets=(
	#     "matadd_16/matadd_16_sr_de" "matadd_16/matadd_16_sr_sVS_de"
	#     "mprove_8/mprove_8_sr_me" "mprove_8/mprove_8_sr_sVS_me"
	#     "svbksb_3/svbksb_3_sr_se" "svbksb_3/svbksb_3_sr_sVS_se"
	# )

	# quad_slda_codelets=(
	#     "lop_13/lop_13_sr_de" "lop_13/lop_13_sr_sVS_de"
	#     "relax2_26/relax2_26_sr_de" "relax2_26/relax2_26_sr_sVS_de"
	#     "rstrct_29/rstrct_29_sr_de" "rstrct_29/rstrct_29_sr_sVS_de"
	# )

	# quadt_s1_codelets=(
	#     "hqr_12/hqr_12_se" "hqr_12/hqr_12_sVS_se"
	#     "ludcmp_4/ludcmp_4_sr_se" "ludcmp_4/ludcmp_4_sr_sVS_se"
	# )

	# ubmk_codelets=("ptr_ld_branch")



	# fill_codelet_maps "${lin_s1_prefix}" "${linear_sizes}" "$(IFS=' '; echo ${lin_s1_codelets[@]})"
	# fill_codelet_maps "${saeed_lin_s1_prefix}" "${linear_sizes}" "$(IFS=' '; echo ${saeed_lin_s1_codelets[@]})"
	# fill_codelet_maps ${lin_slda_prefix} "${linear_sizes}" "$(IFS=' '; echo ${lin_slda_codelets[@]})"
	# fill_codelet_maps ${lin_sclda_prefix} "${linear_clda_sizes}" "$(IFS=' '; echo ${lin_sclda_codelets[@]})"
	# fill_codelet_maps ${quad_s1_prefix} "${quadratic_sizes}" "$(IFS=' '; echo ${quad_s1_codelets[@]})"
	# fill_codelet_maps ${quad_slda_prefix} "${quadratic_sizes}" "$(IFS=' '; echo ${quad_slda_codelets[@]})"
	# fill_codelet_maps ${quadt_s1_prefix} "${quadratic_sizes}" "$(IFS=' '; echo ${quadt_s1_codelets[@]})"
	# fill_codelet_maps ${ubmkprefix} "${ubmk_sizes}" "$(IFS=' '; echo ${ubmk_codelets[@]})"

	fill_codelet_maps "${lin_s1_prefix}" "${linear_sizes}"
	fill_codelet_maps "${saeed_lin_s1_prefix}" "${linear_sizes}"
	fill_codelet_maps "${andy_lin_s1_prefix}" "${linear_sizes}"
	fill_codelet_maps "${andy_quad_s1_prefix}" "${linear_sizes}"
	fill_codelet_maps "${galois_lonestar_prefix}" "${linear_sizes}"
	fill_codelet_maps ${lin_slda_prefix} "${linear_sizes}"
	fill_codelet_maps ${lin_sclda_prefix} "${linear_clda_sizes}"
	fill_codelet_maps ${quad_s1_prefix} "${quadratic_sizes}"
	fill_codelet_maps ${quad_slda_prefix} "${quadratic_sizes}"
	fill_codelet_maps ${quadt_s1_prefix} "${quadratic_sizes}"
	fill_codelet_maps ${ubmkprefix} "${ubmk_sizes}"

	fill_codelet_maps ${amarin_lore_prefix} "${lore_sizes}"

	name2sizes[rstrct_29_de]="2500"
	name2sizes[rstrct_29_sVS_de]="2500"
	name2sizes[hqr_15_se]="600"
	name2sizes[hqr_15_sr_se]="600"





	name2sizes[rstrct_29_de]="355"
	name2sizes[rstrct_29_sVS_de]="355"

	# name2sizes[rstrct_29_sr_de]="355"
	# name2sizes[rstrct_29_sr_sVS_de]="355"

	name2sizes[rstrct_29_sr_de]="100"
	name2sizes[rstrct_29_sr_sVS_de]="100"


	name2sizes[rstrct_29_sr_ls-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld1-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld2-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld3-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld4-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld5-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld6-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld7-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld8-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld9-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld10-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld11-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld12-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld13-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld14-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld15-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld16-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld17-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld18-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld19-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld20-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld21-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld22-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld23-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld24-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld25-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld26-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld27-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld28-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld29-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld30-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld31-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld32-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld33-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld34-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld35-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld36-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld37-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld38-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld39-sVS_de]="355"
	name2sizes[rstrct_29_sr_dld40-sVS_de]="355"


	# name2sizes[relax2_26_sr_de]="304"
	# name2sizes[relax2_26_sr_sVS_de]="304"
	# name2sizes[relax2_26_de]="304"
	# name2sizes[relax2_26_sVS_de]="304"
	# name2sizes[s319_sr_se]="200000"
	# name2sizes[s319_sr_sVS_se]="200000"
	# name2sizes[s319_se]="200000"
	# name2sizes[s319_sVS_se]="200000"
	# name2sizes[s319_sr_se]="100000"
	# name2sizes[s319_sr_sVS_se]="100000"
	# name2sizes[s319_se]="100000"
	# name2sizes[s319_sVS_se]="100000"
	name2sizes[s319_sr_se]="10000"
	name2sizes[s319_sr_sVS_se]="10000"
	name2sizes[s319_se]="10000"
	name2sizes[s319_sVS_se]="10000"
	name2sizes[s1244_sr_se]="10000"
	name2sizes[s1244_sr_sVS_se]="10000"
	name2sizes[s1244_se]="10000"
	name2sizes[s1244_sVS_se]="10000"

	name2sizes[matadd-flb_16_sr_de]="100"
	name2sizes[matadd-flb_16_sr_sVS_de]="100"
	name2sizes[matadd-flb_16_de]="100"
	name2sizes[matadd-flb_16_sVS_de]="100"
	name2sizes[ludcmp-sq_4_se]="100"
	name2sizes[ludcmp-sq_4_sVS_se]="100"
	name2sizes[ludcmp-sq_4_sr_se]="96"
	name2sizes[ludcmp-sq_4_sr_sVS_se]="96"
	name2sizes[ludcmp-sq-no-outer_4_sr_sVS_se]="544"


	# making matadd-flb and lud4-sq datasizes
	name2sizes[matadd_16_sr_de]="352"
	name2sizes[matadd_16_sr_sVS_de]="352"
	name2sizes[matadd_16_de]="352"
	name2sizes[matadd_16_sVS_de]="352"
	name2sizes[ludcmp_4_se]="544"
	name2sizes[ludcmp_4_sVS_se]="544"
	name2sizes[ludcmp_4_sr_se]="544"
	name2sizes[ludcmp_4_sr_sVS_se]="544"

	# new sq variant and matching unmodified runs.

	name2sizes[hqr-sq_12_se]="544"
	name2sizes[hqr-sq_12-no-rip_se]="544"
	name2sizes[hqr-sq_12_sVS_se]="544"

	name2sizes[hqr_12_se]="544"
	name2sizes[hqr_12_sVS_se]="544"


	# Get rid of peel
	# name2sizes[relax2_26_sr_de]="306"
	# name2sizes[relax2_26_sr_sVS_de]="306"
	name2sizes[relax2_26_de]="306"
	name2sizes[relax2_26_sVS_de]="306"
	name2sizes[relax2_26_sr_de]="90"
	name2sizes[relax2_26_sr_sVS_de]="90"
	name2sizes[svbksb_3_sr_se]="96"
	name2sizes[svbksb_3_sr_sVS_se]="96"
	name2sizes[svdcmp_6_de]="992"
	name2sizes[svdcmp_6_sVS_de]="992"



	name2sizes[lop_13_de]="355"
	#name2sizes[lop_13_sVS_de]="355"
	#name2sizes[lop_13_sr_de]="355"
	#name2sizes[lop_13_sr_de]="355 400"
	name2sizes[lop_13_sVS_de]="354"
	name2sizes[lop_13_sr_de]="90"
	name2sizes[lop_13_sr_sVS_de]="90"

	#name2sizes[svbksb_3_sr_ls_se]="390 396"
	#name2sizes[svbksb_3_sr_ls_se]="404 408"
	#name2sizes[svbksb_3_sr_ls-nol1_se]="400"
	name2sizes[svbksb_3_sr_ls-ripl1_se]="400"
	name2sizes[svbksb_3_sr_ls-ripl1_sU6_se]="480"
	name2sizes[svbksb_3_sr_brkdep_se]="400"
	name2sizes[svbksb_3_sr_brkdep1_se]="400"
	name2sizes[svbksb_3_sr_brkdep2_se]="400"
	name2sizes[svbksb_3_sr_brkdep3_se]="400"

	name2sizes[lop_13_sr_ls-sVS_de]="355"

	name2sizes[lop_13_sr_sU8-sVS_de]="355"
	name2sizes[lop_13_sr_ls-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_ls-rip-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_noadds-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_nomuls-simpadds-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_nomuls-alladds-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_rip-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_brkdep-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_nocmplxadds-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_splitadds-sU8-sVS_de]="355"
	name2sizes[lop_13_sr_nocmplxadds1-sU8-sVS_de]="355"

	name2sizes[lop_13_sr_ls_de]="355"
	name2sizes[lop_13_sr_ls1_de]="355 400"

	name2sizes[lop_13_sr_sU8-dld1-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld2-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld3-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld4-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld5-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld6-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld7-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld8-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld9-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld10-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld11-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld12-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld13-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld14-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld15-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld16-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld17-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld18-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld19-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld20-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld21-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld22-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld23-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld24-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld25-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld26-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld27-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld28-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld29-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld30-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld31-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld32-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld33-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld34-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld35-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld36-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld37-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld38-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld39-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld40-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld41-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld42-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld43-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld44-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld45-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld46-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld47-sVS_de]="355"
	name2sizes[lop_13_sr_sU8-dld48-sVS_de]="355"
	name2sizes[lop_13_sr_dld1_de]="355"
	name2sizes[lop_13_sr_dld2_de]="355"
	name2sizes[lop_13_sr_dld3_de]="355"
	name2sizes[lop_13_sr_dld4_de]="355"
	name2sizes[lop_13_sr_dld5_de]="355"
	name2sizes[lop_13_sr_dld6_de]="355"
	name2sizes[lop_13_sr_dld7_de]="355"
	name2sizes[lop_13_sr_dld8_de]="355"
	name2sizes[lop_13_sr_dld9_de]="355"
	name2sizes[lop_13_sr_dld10_de]="355"
	name2sizes[lop_13_sr_dld11_de]="355"
	name2sizes[lop_13_sr_dld12_de]="355"
	name2sizes[lop_13_sr_dld13_de]="355"
	name2sizes[lop_13_sr_dld14_de]="355"
	name2sizes[lop_13_sr_dld15_de]="355"
	name2sizes[lop_13_sr_dld16_de]="355"
	name2sizes[lop_13_sr_dld17_de]="355"
	name2sizes[lop_13_sr_dld18_de]="355"
	name2sizes[lop_13_sr_dld19_de]="355"
	name2sizes[lop_13_sr_dld20_de]="355"
	name2sizes[lop_13_sr_dld21_de]="355"
	name2sizes[lop_13_sr_dld22_de]="355"
	name2sizes[lop_13_sr_dld23_de]="355"
	name2sizes[lop_13_sr_dld24_de]="355"
	name2sizes[lop_13_sr_dld25_de]="355"
	name2sizes[lop_13_sr_l12rip_de]="355"
	name2sizes[lop_13_sr_ls-l12rip_de]="355"
	name2sizes[lop_13_sr_sU3_de]="355"
	name2sizes[lop_13_sr_sU3-dld1_de]="355"
	name2sizes[lop_13_sr_sU3-dld2_de]="355"
	name2sizes[lop_13_sr_sU3-dld3_de]="355"
	name2sizes[lop_13_sr_sU3-dld4_de]="355"
	name2sizes[lop_13_sr_sU3-dld5_de]="355"
	name2sizes[lop_13_sr_sU3-dld6_de]="355"
	name2sizes[lop_13_sr_sU3-dld7_de]="355"
	name2sizes[lop_13_sr_sU3-dld8_de]="355"
	name2sizes[lop_13_sr_sU3-dld9_de]="355"
	name2sizes[lop_13_sr_sU3-dld10_de]="355"
	name2sizes[lop_13_sr_sU3-dld11_de]="355"
	name2sizes[lop_13_sr_sU3-dld12_de]="355"
	name2sizes[lop_13_sr_sU3-dld13_de]="355"
	name2sizes[lop_13_sr_sU3-dld14_de]="355"
	name2sizes[lop_13_sr_sU3-dld15_de]="355"
	name2sizes[lop_13_sr_sU3-dld16_de]="355"
	name2sizes[lop_13_sr_sU3-dld17_de]="355"
	name2sizes[lop_13_sr_sU3-dld18_de]="355"
	name2sizes[lop_13_sr_sU3-dld19_de]="355"
	name2sizes[lop_13_sr_sU3-dld20_de]="355"
	name2sizes[lop_13_sr_sU3-dld21_de]="355"
	name2sizes[lop_13_sr_sU3-dld22_de]="355"
	name2sizes[lop_13_sr_sU3-dld23_de]="355"
	name2sizes[lop_13_sr_sU3-dld24_de]="355"
	name2sizes[lop_13_sr_sU3-dld25_de]="355"
	name2sizes[lop_13_sr_sU3-dld26_de]="355"
	name2sizes[lop_13_sr_sU3-dld27_de]="355"
	name2sizes[lop_13_sr_sU3-dld28_de]="355"
	name2sizes[lop_13_sr_sU3-dld29_de]="355"
	name2sizes[lop_13_sr_sU3-dld30_de]="355"
	name2sizes[lop_13_sr_sU3-dld31_de]="355"
	name2sizes[lop_13_sr_sU3-dld32_de]="355"
	name2sizes[lop_13_sr_sU3-dld33_de]="355"
	name2sizes[lop_13_sr_sU3-dld34_de]="355"
	name2sizes[lop_13_sr_sU3-dld35_de]="355"
	name2sizes[lop_13_sr_sU3-dld36_de]="355"
	name2sizes[lop_13_sr_sU3-dld37_de]="355"
	name2sizes[lop_13_sr_sU3-dld38_de]="355"
	name2sizes[lop_13_sr_sU3-dld39_de]="355"
	name2sizes[lop_13_sr_sU3-dld40_de]="355"
	name2sizes[lop_13_sr_sU3-dld41_de]="355"
	name2sizes[lop_13_sr_sU3-dld42_de]="355"
	name2sizes[lop_13_sr_sU3-dld43_de]="355"
	name2sizes[lop_13_sr_sU3-dld44_de]="355"
	name2sizes[lop_13_sr_sU3-dld45_de]="355"
	name2sizes[lop_13_sr_sU3-dld46_de]="355"
	name2sizes[lop_13_sr_sU3-dld47_de]="355"
	name2sizes[lop_13_sr_sU3-dld48_de]="355"
	name2sizes[lop_13_sr_sU3-dld49_de]="355"
	name2sizes[lop_13_sr_sU3-dld50_de]="355"
	name2sizes[lop_13_sr_sU3-dld51_de]="355"
	name2sizes[lop_13_sr_sU3-dld52_de]="355"
	name2sizes[lop_13_sr_sU3-dld53_de]="355"
	name2sizes[lop_13_sr_sU3-dld54_de]="355"
	name2sizes[lop_13_sr_sU3-dld55_de]="355"
	name2sizes[lop_13_sr_sU3-dld56_de]="355"
	name2sizes[lop_13_sr_sU3-dld57_de]="355"
	name2sizes[lop_13_sr_sU3-dld58_de]="355"
	name2sizes[lop_13_sr_sU3-dld59_de]="355"
	name2sizes[lop_13_sr_sU3-dld60_de]="355"
	name2sizes[lop_13_sr_sU3-dld61_de]="355"
	name2sizes[lop_13_sr_sU3-dld62_de]="355"
	name2sizes[lop_13_sr_sU3-dld63_de]="355"
	name2sizes[lop_13_sr_sU3-dld64_de]="355"
	name2sizes[lop_13_sr_sU3-dld65_de]="355"
	name2sizes[lop_13_sr_sU3-dld66_de]="355"
	name2sizes[lop_13_sr_sU3-dld67_de]="355"
	name2sizes[lop_13_sr_sU3-dld68_de]="355"
	name2sizes[lop_13_sr_sU3-dld69_de]="355"
	name2sizes[lop_13_sr_sU3-dld70_de]="355"
	name2sizes[lop_13_sr_sU3-dld71_de]="355"
	name2sizes[lop_13_sr_sU3-dld72_de]="355"
	name2sizes[lop_13_sr_sU3-dld73_de]="355"
	name2sizes[lop_13_sr_sU3-dld74_de]="355"
	name2sizes[lop_13_sr_sU3-dld75_de]="355"


	name2sizes[toeplz_4_de]="10000"
	name2sizes[toeplz_4_sr_de]="10000"
	#name2sizes[mprove_9_de]="200000"
	#name2sizes[mprove_9_sVS_de]="200000"
	#name2sizes[mprove_9_sr_de]="200000"
	#name2sizes[mprove_9_sr_sVS_de]="200000"


	#name2sizes[toeplz_1_de]="1000 4000 10000 400000"
	#name2sizes[toeplz_1_sVS_de]="1000 4000 10000 400000"


	name2sizes[toeplz_1_de]="4001"
	name2sizes[toeplz_1_sVS_de]="4001"
	name2sizes[tridag_1_sr_de]="1000"

	name2sizes[balanc_3_sr_de]="80000000"
	name2sizes[balanc_3_sr_sVS_de]="80000000"
	name2sizes[elmhes_10_sr_de]="80000000"
	name2sizes[elmhes_10_sr_sVS_de]="80000000"
	name2sizes[elmhes_11_sr_de]="4000000"
	name2sizes[elmhes_11_sr_sVS_de]="4000000"
	name2sizes[four1_2_sr_me]="80000000"
	#name2sizes[hqr_15_sr_se]="30000"
	name2sizes[hqr_15_sr_se]="90000"
	name2sizes[hqr-sq_12_se]="9024"
	name2sizes[hqr-sq_12_sVS_se]="9024"
	# name2sizes[lop_13_sr_de]="9000"
	# name2sizes[lop_13_sr_sVS_de]="9000"
	name2sizes[lop_13_sr_de]="27000"
	name2sizes[lop_13_sr_sVS_de]="27000"
	name2sizes[ludcmp-sq_4_sr_se]="9000"
	name2sizes[ludcmp-sq_4_sr_sVS_se]="9000"


	name2sizes[matadd-flb_16_sr_de]="9000"
	name2sizes[matadd-flb_16_sr_sVS_de]="9000"
	#name2sizes[mprove_8_sr_me]="9000"
	#name2sizes[mprove_8_sr_sVS_me]="9000"
	name2sizes[mprove_8_sr_me]="27000"
	name2sizes[mprove_8_sr_sVS_me]="27000"

	name2sizes[mprove_9_sr_de]="80000000"
	name2sizes[mprove_9_sr_sVS_de]="80000000"

	name2sizes[ptr1_movaps_branch]="4000000"

	name2sizes[realft_4_sr_de]="80000000"
	name2sizes[relax2_26_sr_de]="9002"
	name2sizes[relax2_26_sr_sVS_de]="9002"
	#name2sizes[rstrct_29_sr_de]="9000"
	#name2sizes[rstrct_29_sr_sVS_de]="9000"
	name2sizes[rstrct_29_sr_de]="27000"
	name2sizes[rstrct_29_sr_sVS_de]="27000"



	name2sizes[s1244_sr_se]="80000001"
	name2sizes[s1244_sr_sVS_se]="80000001"

	name2sizes[s319_sr_se]="80000000"
	name2sizes[s319_sr_sVS_se]="80000000"

	#name2sizes[svbksb_3_sr_se]="8000"
	#name2sizes[svbksb_3_sr_sVS_se]="8000"
	name2sizes[svbksb_3_sr_se]="24000"
	name2sizes[svbksb_3_sr_sVS_se]="24000"

	name2sizes[svdcmp_11_sr_de]="4000000"
	name2sizes[svdcmp_11_sr_sVS_de]="4000000"
	name2sizes[svdcmp_13_sr_de]="80000000"
	name2sizes[svdcmp_13_sr_sVS_de]="80000000"

	name2sizes[svdcmp_14_sr_de]="80000000"
	name2sizes[svdcmp_14_sr_sVS_de]="80000000"
	name2sizes[svdcmp_6_de]="4000000"
	name2sizes[svdcmp_6_sVS_de]="4000000"
	name2sizes[toeplz_1_de]="80000001"
	name2sizes[toeplz_1_sVS_de]="80000001"

	name2sizes[toeplz_2_sr_de]="80000000"
	name2sizes[toeplz_4_sr_de]="80000000"
	name2sizes[tridag_1_sr_de]="8000000"
	name2sizes[tridag_2_sr_de]="80000000"

	# Putting last few cases for finding good RAM datasizes
	#name2sizes[hqr_15_sr_se]="6000 10000"
	name2sizes[hqr_15_sr_se]="50000"
	name2sizes[lop_13_sr_de]="13514"
	name2sizes[lop_13_sr_sVS_de]="13514"
	name2sizes[mprove_8_sr_me]="13500"
	name2sizes[mprove_8_sr_sVS_me]="13500"
	name2sizes[rstrct_29_sr_de]="27011"
	name2sizes[rstrct_29_sr_sVS_de]="27011"
	name2sizes[svbksb_3_sr_se]="12000"
	name2sizes[svbksb_3_sr_sVS_se]="12000"





	# #linear_codelets+=" ${lin_s1_prefix}/balanc_3/balanc_3_de"
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/balanc_3/balanc_3_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/balanc_3/balanc_3_sr_sVS_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/elmhes_10/elmhes_10_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/elmhes_10/elmhes_10_sr_sVS_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/four1_2/four1_2_sr_me
	# #linear_codelets+=" ${lin_s1_prefix}/hqr_13/hqr_13_de"
	# #linear_codelets+=" ${lin_s1_prefix}/hqr_13/hqr_13_sVS_de"
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/mprove_9/mprove_9_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/mprove_9/mprove_9_sr_sVS_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/realft_4/realft_4_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/svdcmp_13/svdcmp_13_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/svdcmp_13/svdcmp_13_sr_sVS_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/svdcmp_14/svdcmp_14_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/svdcmp_14/svdcmp_14_sr_sVS_de
	# #linear_codelets+=" ${lin_s1_prefix}/toeplz_1/toeplz_1_de"
	# #linear_codelets+=" ${lin_s1_prefix}/toeplz_1/toeplz_1_sVS_de"
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/toeplz_2/toeplz_2_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/toeplz_4/toeplz_4_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/tridag_1/tridag_1_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_1/tridag_2/tridag_2_sr_de

	# linear_codelets+=" ${saeed_lin_s1_prefix}/s1244/s1244_sr_se"
	# linear_codelets+=" ${saeed_lin_s1_prefix}/s1244/s1244_sr_sVS_se"
	# linear_codelets+=" ${saeed_lin_s1_prefix}/s319/s319_sr_se"
	# linear_codelets+=" ${saeed_lin_s1_prefix}/s319/s319_sr_sVS_se"


	# nr-codelets/numerical_recipes/1D_loop-Stride_CLDA/elmhes_11/elmhes_11_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_CLDA/elmhes_11/elmhes_11_sr_sVS_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_CLDA/svdcmp_11/svdcmp_11_sr_de
	# nr-codelets/numerical_recipes/1D_loop-Stride_CLDA/svdcmp_11/svdcmp_11_sr_sVS_de
	# #linear_codelets+=" ${lin_sclda_prefix}/svdcmp_6/svdcmp_6_de"

	# nr-codelets/numerical_recipes/1D_loop-Stride_LDA/hqr_15/hqr_15_sr_se

	# nr-codelets/numerical_recipes/2D_loop-Stride_1/matadd_16/matadd_16_sr_de
	# nr-codelets/numerical_recipes/2D_loop-Stride_1/matadd_16/matadd_16_sr_sVS_de
	# nr-codelets/numerical_recipes/2D_loop-Stride_1/mprove_8/mprove_8_sr_me
	# nr-codelets/numerical_recipes/2D_loop-Stride_1/mprove_8/mprove_8_sr_sVS_me
	# nr-codelets/numerical_recipes/2D_loop-Stride_1/svbksb_3/svbksb_3_sr_se
	# nr-codelets/numerical_recipes/2D_loop-Stride_1/svbksb_3/svbksb_3_sr_sVS_se

	# nr-codelets/numerical_recipes/2D_loop-Stride_LDA/lop_13/lop_13_sr_de
	# nr-codelets/numerical_recipes/2D_loop-Stride_LDA/lop_13/lop_13_sr_sVS_de
	# nr-codelets/numerical_recipes/2D_loop-Stride_LDA/relax2_26/relax2_26_sr_de
	# nr-codelets/numerical_recipes/2D_loop-Stride_LDA/relax2_26/relax2_26_sr_sVS_de
	# nr-codelets/numerical_recipes/2D_loop-Stride_LDA/rstrct_29/rstrct_29_sr_de
	# nr-codelets/numerical_recipes/2D_loop-Stride_LDA/rstrct_29/rstrct_29_sr_sVS_de

	# #quadratic_codelets+=" ${quadt_s1_prefix}/hqr_12/hqr_12_se"
	# #quadratic_codelets+=" ${quadt_s1_prefix}/hqr_12/hqr_12_sVS_se"
	# nr-codelets/numerical_recipes/2DT_loop-Stride_1/ludcmp_4/ludcmp_4_sr_se
	# nr-codelets/numerical_recipes/2DT_loop-Stride_1/ludcmp_4/ludcmp_4_sr_sVS_se


	orig_only_codelets=(
		hqr_13_de hqr_13_sVS_de
		toeplz_1_de toeplz_1_sVS_de
		svdcmp_6_de svdcmp_6_sVS_de
		hqr_12_se hqr_12_sVS_se
		ptr_ld_branch
	)

	sr_codelets=(
		balanc_3_sr_de balanc_3_sr_sVS_de elmhes_10_sr_de elmhes_10_sr_sVS_de four1_2_sr_me
		mprove_9_sr_de mprove_9_sr_sVS_de realft_4_sr_de
		svdcmp_13_sr_de svdcmp_13_sr_sVS_de svdcmp_14_sr_de svdcmp_14_sr_sVS_de
		toeplz_2_sr_de toeplz_4_sr_de
		tridag_1_sr_de tridag_2_sr_de
		s1244_sr_se s1244_sr_sVS_se s319_sr_se s319_sr_sVS_se
		elmhes_11_sr_de elmhes_11_sr_sVS_de svdcmp_11_sr_de svdcmp_11_sr_sVS_de
		hqr_15_sr_se
		matadd_16_sr_de matadd_16_sr_sVS_de mprove_8_sr_me mprove_8_sr_sVS_me svbksb_3_sr_se svbksb_3_sr_sVS_se
		lop_13_sr_de lop_13_sr_sVS_de relax2_26_sr_de relax2_26_sr_sVS_de rstrct_29_sr_de rstrct_29_sr_sVS_de
		ludcmp_4_sr_se ludcmp_4_sr_sVS_se
	)
	ro_codelets=(${sr_codelets[@]/_sr_/_ro_})
	orig_codelets=(${sr_codelets[@]/_sr_/_} ${orig_only_codelets[@]})

	run_codelets=(
		#     balanc_3_sr_de balanc_3_sr_sVS_de elmhes_10_sr_de elmhes_10_sr_sVS_de four1_2_sr_me
		#     hqr_13_de hqr_13_sVS_de mprove_9_sr_de mprove_9_sr_sVS_de realft_4_sr_de
		#     svdcmp_13_sr_de svdcmp_13_sr_sVS_de svdcmp_14_sr_de svdcmp_14_sr_sVS_de
		#     toeplz_1_de toeplz_1_sVS_de toeplz_2_sr_de toeplz_4_sr_de
		#     tridag_1_sr_de tridag_2_sr_de
		#     s1244_sr_se s1244_sr_sVS_se s319_sr_se s319_sr_sVS_se
		#     elmhes_11_sr_de elmhes_11_sr_sVS_de svdcmp_11_sr_de svdcmp_11_sr_sVS_de svdcmp_6_de svdcmp_6_sVS_de
		#     hqr_15_sr_se
		#     matadd_16_sr_de matadd_16_sr_sVS_de mprove_8_sr_me mprove_8_sr_sVS_me svbksb_3_sr_se svbksb_3_sr_sVS_se
		#     lop_13_sr_de lop_13_sr_sVS_de
		relax2_26_sr_de relax2_26_sr_sVS_de rstrct_29_sr_de rstrct_29_sr_sVS_de
		#     hqr_12_se hqr_12_sVS_se ludcmp_4_sr_se ludcmp_4_sr_sVS_se
		#     ptr_ld_branch
	)

	#variants="DL1"

	# run_codelets=(
	# #    relax2_26_sr_de relax2_26_sr_sVS_de
	# #    relax2_26_de  relax2_26_sVS_de

	# #    rstrct_29_sr_de rstrct_29_sr_sVS_de
	# #    rstrct_29_de  rstrct_29_sVS_de
	#     matadd-flb_16_sr_de matadd-flb_16_sr_sVS_de  matadd-flb_16_de matadd-flb_16_sVS_de
	#     ludcmp-sq_4_se ludcmp-sq_4_sVS_se ludcmp-sq_4_sr_se ludcmp-sq_4_sr_sVS_se
	#     s319_sr_se  s319_sr_sVS_se
	#     s319_se s319_sVS_se
	#     s1244_se s1244_sVS_se
	#     s1244_sr_se s1244_sr_sVS_se

	# )

	# run_codelets=(
	#     lop_13_de lop_13_sVS_de lop_13_sr_de lop_13_sr_sVS_de
	#     relax2_26_de relax2_26_sVS_de relax2_26_sr_de relax2_26_sr_sVS_de
	#     toeplz_4_de toeplz_4_sr_de
	#     tridag_2_de tridag_2_sr_de
	#     mprove_9_de mprove_9_sVS_de mprove_9_sr_de mprove_9_sr_sVS_de
	#     hqr-sq_12_se hqr-sq_12_sVS_se

	#     matadd_16_de matadd_16_sVS_de matadd_16_sr_de matadd_16_sr_sVS_de
	#     ludcmp_4_se ludcmp_4_sVS_se ludcmp_4_sr_se ludcmp_4_sr_sVS_se
	#     hqr_12_se hqr_12_sVS_se
	# )


	run_codelets=(
		${sr_codelets[@]}
		# #    ${ro_codelets[@]}
		${orig_codelets[@]}
	)

	run_codelets=(
		#    balanc_3_sr_de balanc_3_sr_sVS_de elmhes_10_sr_de elmhes_10_sr_sVS_de
		#    elmhes_11_sr_de elmhes_11_sr_sVS_de
		#    four1_2_sr_me
		# #   hqr_12_se hqr_12_sVS_se
		#    hqr_15_sr_se
		#     hqr-sq_12_se hqr-sq_12_sVS_se
		#     lop_13_sr_de lop_13_sr_sVS_de
		# #    ludcmp_4_sr_se ludcmp_4_sr_sVS_se
		#     ludcmp-sq_4_sr_se ludcmp-sq_4_sr_sVS_se
		# #    matadd_16_sr_de matadd_16_sr_sVS_de
		#     matadd-flb_16_sr_de matadd-flb_16_sr_sVS_de
		#     mprove_8_sr_me mprove_8_sr_sVS_me
		#     mprove_9_sr_de mprove_9_sr_sVS_de
		#     ptr_ld_branch
		#     realft_4_sr_de
		#     relax2_26_sr_de relax2_26_sr_sVS_de rstrct_29_sr_de rstrct_29_sr_sVS_de
		#     s1244_sr_se s1244_sr_sVS_se s319_sr_se s319_sr_sVS_se
		#     svbksb_3_sr_se svbksb_3_sr_sVS_se
		svbksb_3_sr_ls_se
		#    svbksb_3_sr_ls-nol1_se
		#    svbksb_3_sr_ls-ripl1_se
		#    svbksb_3_sr_ls-ripl1_sU6_se
		ptr6_movaps-3lfbhit-12rip_branch
		#    ptr6_movaps-3lfbhit_branch
		svbksb_3_sr_brkdep_se
		svbksb_3_sr_brkdep1_se
		svbksb_3_sr_brkdep2_se
		svbksb_3_sr_brkdep3_se
		#     svdcmp_11_sr_de svdcmp_11_sr_sVS_de
		#     svdcmp_13_sr_de svdcmp_13_sr_sVS_de svdcmp_14_sr_de svdcmp_14_sr_sVS_de
		#     svdcmp_6_de svdcmp_6_sVS_de
		#     toeplz_1_de toeplz_1_sVS_de toeplz_2_sr_de toeplz_4_sr_de
		#     tridag_1_sr_de tridag_2_sr_de
	)


	# run_codelets=(
	#  s1244_se s1244_sVS_se  s319_se s319_sVS_se
	#  s1244_sr_se s1244_sr_sVS_se  s319_sr_se s319_sr_sVS_se
	# )


	# run_codelets=(
	#     balanc_3_sr_de balanc_3_sr_sVS_de
	#     balanc_3_ro_de balanc_3_ro_sVS_de
	#     balanc_3_de balanc_3_sVS_de
	#     ptr_ld_branch
	# )

	#run_codelets=(
	#    ludcmp_4_sr_sVS_se
	#    s1244_sr_se
	#    s1244_sr_sVS_se
	#    s1244_se
	#    s1244_sVS_se
	#    s319_sVS_se
	#    s319_se
	#    s319_sr_sVS_se
	#    s319_sr_se
	#    rstrct_29_sr_de
	#    rstrct_29_sr_sVS_de
	#    mprove_9_sr_sVS_de
	#    lop_13_sr_de
	#     mprove_9_de mprove_9_sVS_de mprove_9_sr_de mprove_9_sr_sVS_de
	#     toeplz_4_de toeplz_4_sr_de
	#     tridag_2_de tridag_2_sr_de
	#)


	#  run_codelets=(
	# # #     hqr_13_de
	# #     hqr_15_sr_se
	# #     hqr_15_se
	#      svbksb_3_se svbksb_3_sVS_se
	# )

	# run_codelets=(
	# #    ptr_ld_branch
	# #    ptr2_ld_branch
	# #    ptr3_ld_branch
	# #    ptr4_ld_branch
	#     ptr5_ld_branch
	#     ptr6_ld_branch
	#     ptr7_ld_branch
	#     ptr8_ld_branch
	#     ptr9_ld_branch
	#     ptr10_ld_branch
	#     ptr11_ld_branch
	# )

	# run_codelets=(
	#     ptr_fpld_branch
	# #    movq_1Sx1
	#     ptr1_movaps_branch
	#     ptr2_movaps_branch
	#     ptr3_movaps_branch
	#     ptr4_movaps_branch
	#     ptr5_movaps_branch
	#     ptr6_movaps_branch
	#     ptr7_movaps_branch
	#     ptr8_movaps_branch
	#     ptr9_movaps_branch
	#     ptr10_movaps_branch
	#     ptr11_movaps_branch
	#     ptr1_movaps-2rip_branch
	#     ptr2_movaps-2rip_branch
	#     ptr3_movaps-2rip_branch
	#     ptr4_movaps-2rip_branch
	#     ptr5_movaps-2rip_branch
	#     ptr6_movaps-2rip_branch
	#     ptr7_movaps-2rip_branch
	#     ptr8_movaps-2rip_branch
	#     ptr9_movaps-2rip_branch
	#     ptr10_movaps-2rip_branch
	#     ptr11_movaps-2rip_branch

	# #    ptr1_movsd_branch

	# #    ptr_ld_branch


	# #    ptr3_ld_branch

	# #    ptr5_ld_branch

	# #    ptr7_ld_branch

	# #    ptr9_ld_branch
	# #    ptr10_ld_branch
	# #    loads_1Sx4-s64-movaps
	# #    loads_2Sx4-s64-movaps
	# #    loads_4Sx4-s64-movaps

	# #     ptr2_ld_branch
	# #     ptr4_ld_branch
	# #     ptr6_ld_branch
	# #     ptr8_ld_branch

	# #    hqr_12_sVS_se
	# #    loads_1Sx4-movaps
	# #     loads_1Sx4-movss

	# #    loads_1Sx4-movsd

	# #  loads_1Sx4-movsd_rip loads_1Sx4-movss_rip loads_1Sx4-movups_rip
	# # loads_2Sx4-movaps_rip loads_2Sx4-movsd_rip loads_2Sx4-movss_rip loads_2Sx4-movups_rip
	# # loads_4Sx4-movaps_rip loads_4Sx4-movsd_rip loads_4Sx4-movss_rip loads_4Sx4-movups_rip
	# )

	#name2sizes[ptr_ld_branch]="200"
	#name2sizes[ptr_ld_branch]="200 1000 10000"
	name2sizes[ptr_ld_branch]="10000"
	name2sizes[ptr_fpld_branch]="200 1000 10000"
	name2sizes[movq_1Sx1]="200 1000 10000"
	name2sizes[ptr2_ld_branch]="200 1000 10000"
	name2sizes[ptr3_ld_branch]="200 1000 10000"
	name2sizes[ptr4_ld_branch]="200 1000 10000"
	name2sizes[ptr5_ld_branch]="200 1000 10000"
	name2sizes[ptr6_ld_branch]="200 1000 10000"
	name2sizes[ptr7_ld_branch]="200 1000 10000"
	name2sizes[ptr8_ld_branch]="200 1000 10000"
	name2sizes[ptr9_ld_branch]="200 1000 10000"
	name2sizes[ptr10_ld_branch]="200 1000 10000"
	name2sizes[loads_1Sx4-movaps]="2000 100000 200000"
	name2sizes[loads_1Sx4-movss]="2000 100000 200000"
	name2sizes[loads_1Sx4-movsd]="2000 100000 200000"
	name2sizes[loads_1Sx4-s64-movaps]="2000 100000 200000"
	name2sizes[loads_2Sx4-s64-movaps]="2000 100000 200000"
	name2sizes[loads_4Sx4-s64-movaps]="2000 100000 200000"

	#name2sizes[ptr1_movaps_branch]="200 1000 10000"
	#name2sizes[ptr1_movaps_branch]="1000000"
	#name2sizes[ptr1_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr2_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr3_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr4_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr5_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr6_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr7_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr8_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr9_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr10_movaps_branch]="1000000 1500000 2000000 2500000"
	# name2sizes[ptr11_movaps_branch]="1000000 1500000 2000000 2500000"

	name2sizes[ptr1_movaps_branch]="4000000"
	name2sizes[ptr2_movaps_branch]="4000000"
	name2sizes[ptr3_movaps_branch]="4000000"
	name2sizes[ptr4_movaps_branch]="4000000"
	name2sizes[ptr5_movaps_branch]="4000000"
	name2sizes[ptr6_movaps_branch]="4000000"
	name2sizes[ptr7_movaps_branch]="4000000"
	name2sizes[ptr8_movaps_branch]="4000000"
	name2sizes[ptr9_movaps_branch]="4000000"
	name2sizes[ptr10_movaps_branch]="4000000"
	name2sizes[ptr11_movaps_branch]="4000000"


	name2sizes[ptr1_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr2_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr3_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr4_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr5_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr6_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr7_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr8_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr9_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr10_movaps-2rip_branch]="200 1000 10000"
	name2sizes[ptr11_movaps-2rip_branch]="200 1000 10000"


	name2sizes[ptr2_movaps-15lfbhit-off0_branch]="10000"


	name2sizes[ptr2_movaps-15rip_branch]="10000"

	name2sizes[ptr2_movaps-1lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-2lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-3lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-4lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-5lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-6lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-7lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-8lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-9lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-10lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-11lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-12lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-13lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-14lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-15lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-16lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-17lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-18lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-19lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-20lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-21lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-22lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-23lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-24lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-25lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-26lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-27lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-28lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-29lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-30lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-31lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-32lfbhit_branch]="4000000"
	name2sizes[ptr2_movaps-33lfbhit_branch]="4000000"

	#name2sizes[balanc_3_sr_de]="200000"
	name2sizes[balanc_3_sr_de]="80000000"
	#name2sizes[balanc_3_sr_sVS_de]="200000"
	name2sizes[balanc_3_sr_ls-sVS_de]="200000"
	name2sizes[balanc_3_sr_ls-sU24-sVS_de]="200000"
	name2sizes[balanc_3_sr_ls-sU24-lfb-sVS_de]="200000"

	name2sizes[ptr1_movaps-1lfbhit-s0a32_branch]="10000"
	name2sizes[ptr1_movaps-2lfbhit-s0a32_branch]="10000"

	name2sizes[ptr2_movaps-15lfbhit-s0b-caddr_branch]="10000"
	name2sizes[ptr2_movaps-15lfbhit-s0b-caddr-same-stream_branch]="10000"
	name2sizes[ptr2_movaps-15lfbhit-s4b-caddr_branch]="10000"
	name2sizes[ptr2_movaps-15lfbhit-s4b-caddr-same-stream_branch]="10000"
	name2sizes[ptr2_movaps-15lfbhit-s8b-caddr_branch]="10000"
	name2sizes[ptr2_movaps-15lfbhit-s8b-caddr-same-stream_branch]="10000"
	name2sizes[ptr2_movaps-15lfbhit-s0a32-caddr_branch]="10000"

	name2sizes[ptr3_movaps-15lfbhit_branch]="10000"
	name2sizes[ptr3_movaps-15lfbhit-s0b_branch]="10000"
	name2sizes[ptr3_movaps-15lfbhit-s8b_branch]="10000"
	name2sizes[ptr3_movaps-15lfbhit-s8b-caddr_branch]="10000"
	name2sizes[ptr3_movaps-15lfbhit-s0b-caddr_branch]="10000"
	name2sizes[ptr3_movaps-15lfbhit-s8b-caddr-same-stream_branch]="10000"
	name2sizes[ptr3_movaps-15lfbhit-s0b-caddr-same-stream_branch]="10000"
	name2sizes[ptr3_movaps-15lfbhit-s0a32-caddr_branch]="10000"

	name2sizes[ptr4_movaps-15lfbhit_branch]="10000"

	name2sizes[ptr1_movaps-1lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-2lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-3lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-4lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-5lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-6lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-7lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-8lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-9lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-10lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-11lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-12lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-13lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-14lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-15lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-16lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-17lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-18lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-19lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-20lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-21lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-22lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-23lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-24lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-25lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-26lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-27lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-28lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-29lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-30lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-31lfbhit_branch]="4000000"
	name2sizes[ptr1_movaps-32lfbhit_branch]="4000000"

	# name2sizes[ptr1_movaps-1lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-2lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-3lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-4lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-5lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-6lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-7lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-8lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-9lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-10lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-11lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-12lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-13lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-14lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-15lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-16lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-17lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-18lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-19lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-20lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-21lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-22lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-23lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-24lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-25lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-26lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-27lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-28lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-29lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-30lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-31lfbhit_branch]="200"
	# name2sizes[ptr1_movaps-32lfbhit_branch]="200"


	name2sizes[ptr4_movaps-1lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-2lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-3lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-4lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-5lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-6lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-7lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-8lfbhit_branch]="4000000"
	name2sizes[ptr4_movaps-9lfbhit_branch]="4000000"

	name2sizes[ptr1_vmovaps-1lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-2lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-3lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-4lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-5lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-6lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-7lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-8lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-9lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-10lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-11lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-12lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-13lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-14lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-15lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-16lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-17lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-18lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-19lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-20lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-21lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-22lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-23lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-24lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-25lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-26lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-27lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-28lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-29lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-30lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-31lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps-32lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-1lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-2lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-3lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-4lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-5lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-6lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-7lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-8lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-9lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-10lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-11lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-12lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-13lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-14lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-15lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-16lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-17lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-18lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-19lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-20lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-21lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-22lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-23lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-24lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-25lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-26lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-27lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-28lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-29lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-30lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-31lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-32lfbhit_branch]="10000"
	name2sizes[ptr2_vmovaps-33lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-1lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-2lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-3lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-4lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-5lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-6lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-7lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-8lfbhit_branch]="10000"
	name2sizes[ptr4_vmovaps-9lfbhit_branch]="10000"
	name2sizes[ptr1_vmovaps_branch]="10000"
	name2sizes[ptr2_vmovaps_branch]="10000"
	name2sizes[ptr3_vmovaps_branch]="10000"
	name2sizes[ptr4_vmovaps_branch]="10000"
	name2sizes[ptr5_vmovaps_branch]="10000"
	name2sizes[ptr6_vmovaps_branch]="10000"
	name2sizes[ptr7_vmovaps_branch]="10000"
	name2sizes[ptr8_vmovaps_branch]="10000"
	name2sizes[ptr9_vmovaps_branch]="10000"
	name2sizes[ptr10_vmovaps_branch]="10000"
	name2sizes[ptr11_vmovaps_branch]="10000"


	name2sizes[ptr6_movaps-3lfbhit-12rip_branch]="10000"
	name2sizes[ptr6_movaps-3lfbhit_branch]="10000"
	name2sizes[sp.c_lhsx_line885_loop.c.0_dx2]="64"
	name2sizes[sp.c_lhsx_line885_loop.c.0_sVS_dx2]="64"
	name2sizes[cg.c_main_line271_loop.c.0_dx2]="64"
	name2sizes[sp.c_lhsy_line1028_loop.c.0_de]="64"
	name2sizes[cg.c_main_line271_loop.c.0_dx2]=64
	name2sizes[cg.c_main_line271_loop.c.0_dx]=64
	name2sizes[cg.c_main_line271_loop.c.0_de]=64
	name2sizes[sp.c_lhsy_line1028_loop.c.0_de]=64
	name2sizes[sp.c_lhsy_line1028_loop.c.0_dx]=64
	name2sizes[sp.c_lhsy_line1028_loop.c.0_dx2]=64
	name2sizes[Crystal_div.c_Crystal_div_line65_loop.c.0_de]=64
	name2sizes[Crystal_div.c_Crystal_div_line65_loop.c.0_dx]=64
	name2sizes[Crystal_div.c_Crystal_div_line65_loop.c.0_dx2]=64
	name2sizes[bfs-load-preloaded_sVS_ig]="rmat22.gr:4 rmat22.gr:5 rmat22.gr:6"
	name2sizes[bfs-load-preloaded-sort_sVS_ig]="rmat22.gr:1:4 rmat22.gr:1:5 rmat22.gr:1:6"
	name2sizes[bfs-load-preloaded-nosub_sVS_ig]="rmat22.gr:4 rmat22.gr:5 rmat22.gr:6"
	name2sizes[bfs-load-preloaded-sort-nosub_sVS_ig]="rmat22.gr:1:4 rmat22.gr:1:5 rmat22.gr:1:6"
	#name2sizes[bfs-load-preloaded-noaddsub_sVS_ig]="rmat22.gr:4 rmat22.gr:5 rmat22.gr:6"
	#name2sizes[bfs-load-preloaded-noaddsub_sVS_ig]="2G-sorted-stride.gr:0 2G-random-stride.gr:0"
	#name2sizes[bfs-load-preloaded-sort-noaddsub_sVS_ig]="rmat22.gr:1:4 rmat22.gr:1:5 rmat22.gr:1:6"
	#name2sizes[bfs-load-preloaded-sort-noaddsub_sVS_ig]="rmat22.gr:0:4"
	name2sizes[bfs-load-preloaded-sort-noaddsub_sVS_ig]="rmat22.gr:0:2 rmat22.gr:0:3 rmat22.gr:0:4 rmat22.gr:0:5 rmat22.gr:0:6 rmat22.gr:0:7 rmat22.gr:0:8 rmat22.gr:0:9 rmat22.gr:0:10 rmat22.gr:0:11 rmat22.gr:0:12"
	#name2sizes[bfs-load-preloaded-sort-noaddsub_sVS_ig]="1G-sorted-stride.gr:0:0 1G-random-stride.gr:0:0"
	#name2sizes[bfs-load-preloaded-sort-noaddsub_sVS_ig]="1G-sorted-stride.gr:0:0"
	#name2sizes[bfs-load-preloaded_sVS_ig]="rmat22.gr:0 rmat22.gr:1 rmat22.gr:2 rmat22.gr:3 rmat22.gr:7 rmat22.gr:8 rmat22.gr:9 rmat22.gr:10 rmat22.gr:11 rmat22.gr:12 rmat22.gr:13"
	#name2sizes[bfs-load-preloaded_sVS_ig]=100
	name2sizes[bfs-pull-topo-async_ig]="rmat22.gr:0:-1"
	#name2sizes[bfs-pull-topo-sync_ix2]="rmat22.gr:0:-1"
	name2sizes[bfs-pull-topo-sync_ix2]="rmat22.gr:0:-1 wikipedia-20051105-transpose.gr:0:-1 rmat16-2e22-transpose.gr:0:-1 USA-road-d.NY-transpose.gr:0:-1 USA-road-d.FLA-transpose.gr:0:-1"
	name2sizes[bfs-pull-topo-sync_ix2]="rmat22.gr:0:-1 wikipedia-20051105-transpose.gr:0:-1"
	name2sizes[bfs-push-data-sync_ix2]="rmat22.gr:0:-1 wikipedia-20051105.gr:0:-1 rmat16-2e22.gr:0:-1 USA-road-d.NY.gr:0:-1 USA-road-d.FLA.gr:0:-1 USA-road-d.USA.gr:0:-1"
	#name2sizes[bfs-push-data-sync_ix2]="USA-road-d.USA.gr:0:-1"
	#name2sizes[bfs-push-data-sync_ix2]="USA-road-d.W.gr:0:-1"
	name2sizes[bfs-push-data-sync_ix2]="rmat16-2e22.gr:0:-1"
	name2sizes[bfs-push-data-async_ix2]="wikipedia-20051105.gr:0:-1 rmat16-2e22.gr:0:-1 USA-road-d.W.gr:0:-1"
	name2sizes[bfs-push-data-sync_ix2]="wikipedia-20051105.gr:0:-1 rmat16-2e22.gr:0:-1 USA-road-d.W.gr:0:-1"
	name2sizes[bfs-push-data-async-stldeq_ix2]="wikipedia-20051105.gr:0:-1 rmat16-2e22.gr:0:-1 USA-road-d.W.gr:0:-1"
	name2sizes[bfs-push-data-sync-fifo_ix2]="wikipedia-20051105.gr:0:-1 rmat16-2e22.gr:0:-1 USA-road-d.W.gr:0:-1"
	#name2sizes[bfs-push-data-sync_ix2]="rmat22.gr:0:-1"
	name2sizes[bfs-pull-topo-async_ig]="rmat22.gr:0:-1 wikipedia-20051105-transpose.gr:0:-1 rmat16-2e22-transpose.gr:0:-1 USA-road-d.NY-transpose.gr:0:-1 USA-road-d.FLA-transpose.gr:0:-1"
	#name2sizes[pr-sync-pull]="rmat22.gr:0:-1 wikipedia-20051105-transpose.gr:0:-1 rmat16-2e22-transpose.gr:0:-1"
	name2sizes[pr-sync-pull]="USA-road-transpose.gr:0:-1"
	#name2sizes[pr-pull-topo-sync_dx2]="USA-road-d.NY-transpose.gr:0:-1 USA-road-d.FLA-transpose.gr:0:-1"
	name2sizes[pr-pull-topo-sync_dx2]="wikipedia-20051105-transpose.gr:0:-1 rmat16-2e22-transpose.gr:0:-1 USA-road-d.NY-transpose.gr:0:-1 USA-road-d.FLA-transpose.gr:0:-1 rmat22.gr:0:-1"
	#name2sizes[pr-pull-topo-async]="wikipedia-20051105-transpose.gr:0:-1 rmat16-2e22-transpose.gr:0:-1 USA-road-d.NY-transpose.gr:0:-1 USA-road-d.FLA-transpose.gr:0:-1 rmat22.gr:0:-1"
	name2sizes[pr-pull-topo-async]="wikipedia-20051105-transpose.gr:0:-1 rmat16-2e22-transpose.gr:0:-1 USA-road-d.W-transpose.gr:0:-1"

	name2sizes[sssp-pull-topo-async]="rmat16-2e22-transpose.gr:0:-1 USA-road-d.NY-transpose.gr:0:-1"
	name2sizes[sssp-pull-topo-sync_ix2]="rmat16-2e22-transpose.gr:0:-1 USA-road-d.NY-transpose.gr:0:-1"
	name2sizes[sssp-push-delta-sync_ix2]="rmat16-2e22.gr:13:-1 USA-road-d.W.gr:13:-1 wikipedia-20051105-weighted.gr:13:-1"
	name2sizes[sssp-push-delta-async_ix2]="rmat16-2e22.gr:13:-1 USA-road-d.W.gr:13:-1 wikipedia-20051105-weighted.gr:13:-1"
	#name2sizes[sssp-push-delta-sync_ix2]="wikipedia-20051105-weighted.gr:13:-1"
	#name2sizes[sssp-push-delta-async_ix2]="wikipedia-20051105-weighted.gr:13:-1"

	#name2sizes[cc-pull-topo-sync_ix2]="rmat16-2e22-sym.gr:0:-1"
	name2sizes[cc-pull-topo-async]="wikipedia-20051105-symmetric.gr:0:-1 rmat16-2e22-sym.gr:0:-1 USA-road-d.NY-symmetric.gr:0:-1 rmat22.sym.gr:0:-1"
	name2sizes[cc-pull-topo-sync_ix2]="wikipedia-20051105-symmetric.gr:0:-1 rmat16-2e22-sym.gr:0:-1 USA-road-d.NY-symmetric.gr:0:-1 rmat22.sym.gr:0:-1"
	name2sizes[cc-uf-id_ix2]="wikipedia-20051105-symmetric.gr:0:-1 rmat16-2e22-sym.gr:0:-1 USA-road-d.W-symmetric.gr:0:-1"
	name2sizes[cc-uf-topo-node_ix2]="wikipedia-20051105-symmetric.gr:0:-1 rmat16-2e22-sym.gr:0:-1 USA-road-d.W-symmetric.gr:0:-1"

	name2sizes[balanc_3_dx2]="80000000"
	name2sizes[balanc_3_sVS_dx2]="80000000"
	name2sizes[elmhes_10_dx2]="80000000"
	name2sizes[elmhes_10_sVS_dx2]="80000000"
	name2sizes[elmhes_11_dx2]="4000000"
	name2sizes[elmhes_11_sVS_dx2]="4000000"
	name2sizes[four1_2_mx2]="80000000"
	name2sizes[hqr_15_sx2]="50000"
	name2sizes[hqr-sq_12_sx2]="9024"
	name2sizes[hqr-sq_12_sVS_sx2]="9024"
	name2sizes[lop_13_dx2]="13524"
	name2sizes[lop_13_sVS_dx2]="13524"
	name2sizes[ludcmp-sq_4_sx2]="9008"
	name2sizes[ludcmp-sq_4_sVS_sx2]="9008"
	name2sizes[matadd-flb_16_dx2]="9008"
	name2sizes[matadd-flb_16_sVS_dx2]="9008"
	name2sizes[mprove_8_mx2]="13504"
	name2sizes[mprove_8_sVS_mx2]="13504"
	name2sizes[mprove_9_dx2]="80000000"
	name2sizes[mprove_9_sVS_dx2]="80000000"
	name2sizes[ptr1_vmovaps_branch]="4000000"
	name2sizes[realft_4_dx2]="80000000"
	name2sizes[relax2_26_dx2]="9002"
	name2sizes[relax2_26_sVS_dx2]="9002"
	name2sizes[rstrct_29_dx2]="27016"
	name2sizes[rstrct_29_sVS_dx2]="27016"
	name2sizes[s1244_sx2]="80000001"
	name2sizes[s1244_sVS_sx2]="80000001"
	name2sizes[s319_sx2]="80000000"
	name2sizes[s319_sVS_sx2]="80000000"
	name2sizes[svbksb_3_sx2]="12000"
	name2sizes[svbksb_3_sVS_sx2]="12000"
	name2sizes[svdcmp_11_dx2]="400000"
	name2sizes[svdcmp_11_sVS_dx2]="4000000"
	name2sizes[svdcmp_13_dx2]="80000000"
	name2sizes[svdcmp_13_sVS_dx2]="80000000"
	name2sizes[svdcmp_14_dx2]="80000000"
	name2sizes[svdcmp_14_sVS_dx2]="80000000"
	name2sizes[svdcmp_6_dx2]="4000000"
	name2sizes[svdcmp_6_sVS_dx2]="4000000"
	name2sizes[toeplz_1_dx2]="80000001"
	name2sizes[toeplz_1_sVS_dx2]="80000001"
	name2sizes[toeplz_2_dx2]="80000000"
	name2sizes[toeplz_4_dx2]="80000000"
	name2sizes[tridag_1_dx2]="8000000"
	name2sizes[tridag_2_dx2]="80000000"



	# Switched focus to 2D
	# run_codelets=(
	# # # #hqr-sq_12_se hqr-sq_12_sVS_se
	# # # #hqr-sq-no-tail_12_se hqr-sq-no-tail_12_sVS_se
	# # # #hqr-sq-no-tail_12_se hqr-sq-no-tail_12_sVS_se
	# # # #hqr-1d_12_se hqr-1d_12_sVS_se
	# # # #hqr-1d_12_fp-w-rip-sVS_se
	# # # #hqr-1d_12_fp-no-rip-sVS_se
	# # # #hqr-1d_12_ls-sVS_se
	# # # #hqr-1d_12_no-andps-sVS_se
	# # # #hqr-1d_12_no-red-sVS_se
	# # # #hqr-1d_12_no-rip-sVS_se
	# # # #hqr-1d_12_sU8-sVS_se
	# # # #hqr-1ds64_12_sVS_se
	# # # #hqr-1ds64_12_ls-sVS_se
	# #hqr-1d_12_ls_se
	# #hqr-1d_12_ls-no-rip_se
	# #hqr-sq_12-no-rip_se
	# # # #ludcmp-sq_4_sr_sVS_se
	# # # #ludcmp-sq-no-outer_4_sr_sVS_se

	# # # balanc_3_sr_sVS_de
	# # # balanc_3_sr_ls-sVS_de

	# # # #ptr1_movaps-15lfbhit_branch

	# # # #ptr2_movaps-15rip_branch
	# # # #ptr2_movaps-15lfbhit-off0_branch



	# # # # ptr1_movaps-1lfbhit_branch
	# # # # ptr1_movaps-2lfbhit_branch
	# # # # ptr1_movaps-3lfbhit_branch
	# # # # ptr1_movaps-4lfbhit_branch
	# # # # ptr1_movaps-5lfbhit_branch
	# # # # ptr1_movaps-6lfbhit_branch
	# # # # ptr1_movaps-7lfbhit_branch
	# # # # ptr1_movaps-8lfbhit_branch
	# # # # ptr1_movaps-9lfbhit_branch
	# # # # ptr1_movaps-10lfbhit_branch
	# # # # ptr1_movaps-11lfbhit_branch
	# # # # ptr1_movaps-12lfbhit_branch
	# # # # ptr1_movaps-13lfbhit_branch
	# # # # ptr1_movaps-14lfbhit_branch
	# # # # ptr1_movaps-15lfbhit_branch
	# # # # ptr1_movaps-16lfbhit_branch
	# # # # ptr1_movaps-17lfbhit_branch
	# # # # ptr1_movaps-18lfbhit_branch
	# # # # ptr1_movaps-19lfbhit_branch

	# # # # ptr1_movaps-20lfbhit_branch
	# # # # ptr1_movaps-21lfbhit_branch
	# # # # ptr1_movaps-22lfbhit_branch
	# # # # ptr1_movaps-23lfbhit_branch
	# # # # ptr1_movaps-24lfbhit_branch
	# # # # ptr1_movaps-25lfbhit_branch
	# # # # ptr1_movaps-26lfbhit_branch
	# # # # ptr1_movaps-27lfbhit_branch
	# # # # ptr1_movaps-28lfbhit_branch
	# # # # ptr1_movaps-29lfbhit_branch
	# # # # ptr1_movaps-30lfbhit_branch
	# # # # ptr1_movaps-31lfbhit_branch
	# # # # ptr1_movaps-32lfbhit_branch

	# # # # ptr2_movaps-1lfbhit_branch
	# # # # ptr2_movaps-2lfbhit_branch
	# # # # ptr2_movaps-3lfbhit_branch
	# # # # ptr2_movaps-4lfbhit_branch
	# # # # ptr2_movaps-5lfbhit_branch
	# # # # ptr2_movaps-6lfbhit_branch
	# # # # ptr2_movaps-7lfbhit_branch
	# # # # ptr2_movaps-8lfbhit_branch
	# # # # ptr2_movaps-9lfbhit_branch
	# # # # ptr2_movaps-10lfbhit_branch
	# # # # ptr2_movaps-11lfbhit_branch
	# # # # ptr2_movaps-12lfbhit_branch
	# # # # ptr2_movaps-13lfbhit_branch
	# # # # ptr2_movaps-14lfbhit_branch
	# # # # ptr2_movaps-15lfbhit_branch

	# # ptr2_movaps-23lfbhit_branch
	# # ptr2_movaps-24lfbhit_branch
	# # ptr2_movaps-27lfbhit_branch
	# # ptr2_movaps-28lfbhit_branch
	# # ptr2_movaps-31lfbhit_branch
	# # ptr2_movaps-32lfbhit_branch

	# # ptr2_movaps-16lfbhit_branch
	# # ptr2_movaps-17lfbhit_branch
	# # ptr2_movaps-18lfbhit_branch
	# # ptr2_movaps-19lfbhit_branch
	# # ptr2_movaps-20lfbhit_branch
	# # ptr2_movaps-21lfbhit_branch
	# # ptr2_movaps-22lfbhit_branch
	# # ptr2_movaps-25lfbhit_branch
	# # ptr2_movaps-26lfbhit_branch
	# # ptr2_movaps-29lfbhit_branch
	# # ptr2_movaps-30lfbhit_branch
	# # ptr2_movaps-33lfbhit_branch



	# # # # ptr2_movaps-15lfbhit-s0b-caddr_branch
	# # # # ptr2_movaps-15lfbhit-s0b-caddr-same-stream_branch
	# # # # ptr2_movaps-15lfbhit-s4b-caddr_branch
	# # # # ptr2_movaps-15lfbhit-s4b-caddr-same-stream_branch
	# # # # ptr2_movaps-15lfbhit-s8b-caddr_branch
	# # # # ptr2_movaps-15lfbhit-s8b-caddr-same-stream_branch


	# # # #balanc_3_sr_ls-sVS_de
	# # # #ptr3_movaps-15lfbhit_branch
	# # # #ptr4_movaps-15lfbhit_branch
	# # # #balanc_3_sr_ls-sU24-sVS_de
	# # # #balanc_3_sr_ls-sU24-lfb-sVS_de
	# # # #ptr3_movaps-15lfbhit-s0b_branch
	# # # #ptr3_movaps-15lfbhit-s8b_branch
	# # ptr3_movaps-15lfbhit-s8b-caddr_branch
	# # ptr3_movaps-15lfbhit-s0b-caddr_branch
	# # ptr3_movaps-15lfbhit-s8b-caddr-same-stream_branch
	# # ptr3_movaps-15lfbhit-s0b-caddr-same-stream_branch

	# #ptr1_movaps-15lfbhit-s0a32_branch
	# #ptr1_movaps-1lfbhit-s0a32_branch
	# #ptr1_movaps-2lfbhit-s0a32_branch
	# #ptr1_movaps-15lfbhit-s0a32_branch

	# #ptr2_movaps-15lfbhit-s0a32-caddr_branch
	# #ptr3_movaps-15lfbhit-s0a32-caddr_branch

	# # # # ptr4_movaps-1lfbhit_branch
	# # # # ptr4_movaps-2lfbhit_branch
	# # # # ptr4_movaps-3lfbhit_branch
	# # # # ptr4_movaps-4lfbhit_branch
	# # # # ptr4_movaps-5lfbhit_branch
	# # # # ptr4_movaps-6lfbhit_branch
	# # # # ptr4_movaps-7lfbhit_branch
	# # # # ptr4_movaps-8lfbhit_branch
	# # # # ptr4_movaps-9lfbhit_branch

	# # rstrct_29_sr_dld1-sVS_de
	# # rstrct_29_sr_dld4-sVS_de
	# # rstrct_29_sr_dld7-sVS_de
	# # rstrct_29_sr_dld10-sVS_de
	# # rstrct_29_sr_dld13-sVS_de
	# # rstrct_29_sr_dld16-sVS_de
	# # rstrct_29_sr_dld19-sVS_de
	# # rstrct_29_sr_dld22-sVS_de
	# # rstrct_29_sr_dld25-sVS_de
	# # rstrct_29_sr_dld28-sVS_de
	# # rstrct_29_sr_dld31-sVS_de
	# # rstrct_29_sr_dld34-sVS_de
	# # rstrct_29_sr_dld37-sVS_de
	# # rstrct_29_sr_dld40-sVS_de

	# # rstrct_29_sr_sVS_de
	# # rstrct_29_sr_ls-sVS_de
	# # rstrct_29_sr_dld2-sVS_de
	# # rstrct_29_sr_dld3-sVS_de
	# # rstrct_29_sr_dld5-sVS_de
	# # rstrct_29_sr_dld6-sVS_de
	# # rstrct_29_sr_dld8-sVS_de
	# # rstrct_29_sr_dld9-sVS_de

	# # rstrct_29_sr_dld11-sVS_de
	# # rstrct_29_sr_dld12-sVS_de

	# # rstrct_29_sr_dld14-sVS_de
	# # rstrct_29_sr_dld15-sVS_de

	# # rstrct_29_sr_dld17-sVS_de
	# # rstrct_29_sr_dld18-sVS_de

	# # rstrct_29_sr_dld20-sVS_de
	# # rstrct_29_sr_dld21-sVS_de

	# # rstrct_29_sr_dld23-sVS_de
	# # rstrct_29_sr_dld24-sVS_de

	# # rstrct_29_sr_dld26-sVS_de
	# # rstrct_29_sr_dld27-sVS_de

	# # rstrct_29_sr_dld29-sVS_de
	# # rstrct_29_sr_dld30-sVS_de

	# # rstrct_29_sr_dld32-sVS_de
	# # rstrct_29_sr_dld33-sVS_de

	# # rstrct_29_sr_dld35-sVS_de
	# # rstrct_29_sr_dld36-sVS_de

	# # rstrct_29_sr_dld38-sVS_de
	# # rstrct_29_sr_dld39-sVS_de

	# #lop_13_sr_ls-sVS_de

	# #lop_13_sr_sU8-sVS_de
	# # lop_13_sr_sU8-dld1-sVS_de
	# # lop_13_sr_sU8-dld2-sVS_de
	# # lop_13_sr_sU8-dld3-sVS_de
	# # lop_13_sr_sU8-dld4-sVS_de
	# # lop_13_sr_sU8-dld5-sVS_de
	# # lop_13_sr_sU8-dld6-sVS_de
	# # lop_13_sr_sU8-dld7-sVS_de
	# # lop_13_sr_sU8-dld8-sVS_de
	# # lop_13_sr_sU8-dld9-sVS_de
	# # lop_13_sr_sU8-dld10-sVS_de
	# # lop_13_sr_sU8-dld11-sVS_de
	# # lop_13_sr_sU8-dld12-sVS_de
	# # lop_13_sr_sU8-dld13-sVS_de
	# # lop_13_sr_sU8-dld14-sVS_de
	# # lop_13_sr_sU8-dld15-sVS_de
	# # lop_13_sr_sU8-dld16-sVS_de
	# # lop_13_sr_sU8-dld17-sVS_de
	# # lop_13_sr_sU8-dld18-sVS_de
	# # lop_13_sr_sU8-dld19-sVS_de
	# # lop_13_sr_sU8-dld20-sVS_de
	# # lop_13_sr_sU8-dld21-sVS_de
	# # lop_13_sr_sU8-dld22-sVS_de
	# # lop_13_sr_sU8-dld23-sVS_de
	# # lop_13_sr_sU8-dld24-sVS_de
	# # lop_13_sr_sU8-dld25-sVS_de
	# # lop_13_sr_sU8-dld26-sVS_de
	# # lop_13_sr_sU8-dld27-sVS_de
	# # lop_13_sr_sU8-dld28-sVS_de
	# # lop_13_sr_sU8-dld29-sVS_de
	# # lop_13_sr_sU8-dld30-sVS_de
	# # lop_13_sr_sU8-dld31-sVS_de
	# # lop_13_sr_sU8-dld32-sVS_de
	# # lop_13_sr_sU8-dld33-sVS_de
	# # lop_13_sr_sU8-dld34-sVS_de
	# # lop_13_sr_sU8-dld35-sVS_de
	# # lop_13_sr_sU8-dld36-sVS_de
	# # lop_13_sr_sU8-dld37-sVS_de
	# # lop_13_sr_sU8-dld38-sVS_de
	# # lop_13_sr_sU8-dld39-sVS_de
	# # lop_13_sr_sU8-dld40-sVS_de
	# # lop_13_sr_sU8-dld41-sVS_de
	# # lop_13_sr_sU8-dld42-sVS_de
	# # lop_13_sr_sU8-dld43-sVS_de
	# # lop_13_sr_sU8-dld44-sVS_de
	# # lop_13_sr_sU8-dld45-sVS_de
	# # lop_13_sr_sU8-dld46-sVS_de
	# # lop_13_sr_sU8-dld47-sVS_de
	# # lop_13_sr_sU8-dld48-sVS_de
	# #lop_13_sr_ls-sU8-sVS_de
	# #lop_13_sr_ls-rip-sU8-sVS_de
	# #lop_13_sr_noadds-sU8-sVS_de
	# #lop_13_sr_nomuls-simpadds-sU8-sVS_de
	# #lop_13_sr_nomuls-alladds-sU8-sVS_de
	# #lop_13_sr_rip-sU8-sVS_de
	# #lop_13_sr_brkdep-sU8-sVS_de
	# #lop_13_sr_nocmplxadds-sU8-sVS_de
	# #lop_13_sr_splitadds-sU8-sVS_de
	# #lop_13_sr_nocmplxadds1-sU8-sVS_de

	# lop_13_sr_sVS_de

	# #lop_13_sr_ls_de

	# # lop_13_sr_dld1_de
	# # lop_13_sr_dld2_de
	# # lop_13_sr_dld3_de
	# # lop_13_sr_dld4_de
	# # lop_13_sr_dld5_de
	# # lop_13_sr_dld6_de
	# # lop_13_sr_dld7_de
	# # lop_13_sr_dld8_de
	# # lop_13_sr_dld9_de
	# # lop_13_sr_dld10_de
	# # lop_13_sr_dld11_de
	# # lop_13_sr_dld12_de
	# # lop_13_sr_dld13_de
	# # lop_13_sr_dld14_de
	# # lop_13_sr_dld15_de
	# # lop_13_sr_dld16_de
	# # lop_13_sr_dld17_de
	# # lop_13_sr_dld18_de
	# # lop_13_sr_dld19_de
	# # lop_13_sr_dld20_de
	# # lop_13_sr_dld21_de
	# # lop_13_sr_dld22_de
	# # lop_13_sr_dld23_de
	# # lop_13_sr_dld24_de
	# # lop_13_sr_dld25_de
	# lop_13_sr_de
	# #lop_13_sr-l12rip_de
	# #lop_13_sr_ls-l12rip_de
	# #lop_13_sr_ls_de
	# # lop_13_sr_sU3_de
	# # lop_13_sr_sU3-dld1_de
	# # # lop_13_sr_sU3-dld2_de
	# # # lop_13_sr_sU3-dld3_de
	# # # lop_13_sr_sU3-dld4_de
	# # lop_13_sr_sU3-dld5_de
	# # # lop_13_sr_sU3-dld6_de
	# # # lop_13_sr_sU3-dld7_de
	# # lop_13_sr_sU3-dld8_de
	# # # lop_13_sr_sU3-dld9_de
	# # # lop_13_sr_sU3-dld10_de
	# # # lop_13_sr_sU3-dld11_de
	# # # lop_13_sr_sU3-dld12_de
	# # # lop_13_sr_sU3-dld13_de
	# # # lop_13_sr_sU3-dld14_de
	# # # lop_13_sr_sU3-dld15_de
	# # # lop_13_sr_sU3-dld16_de
	# # lop_13_sr_sU3-dld17_de
	# # lop_13_sr_sU3-dld18_de
	# # # lop_13_sr_sU3-dld19_de
	# # # lop_13_sr_sU3-dld20_de
	# # # lop_13_sr_sU3-dld21_de
	# # # lop_13_sr_sU3-dld22_de
	# # lop_13_sr_sU3-dld23_de
	# # lop_13_sr_sU3-dld24_de
	# # lop_13_sr_sU3-dld25_de
	# # lop_13_sr_sU3-dld26_de
	# # # lop_13_sr_sU3-dld27_de
	# # # lop_13_sr_sU3-dld28_de
	# # # lop_13_sr_sU3-dld29_de
	# # lop_13_sr_sU3-dld30_de
	# # # lop_13_sr_sU3-dld31_de
	# # # lop_13_sr_sU3-dld32_de
	# # lop_13_sr_sU3-dld33_de
	# # # lop_13_sr_sU3-dld34_de
	# # # lop_13_sr_sU3-dld35_de
	# # # lop_13_sr_sU3-dld36_de
	# # # lop_13_sr_sU3-dld37_de
	# # # lop_13_sr_sU3-dld38_de
	# # # lop_13_sr_sU3-dld39_de
	# # # lop_13_sr_sU3-dld40_de
	# # # lop_13_sr_sU3-dld41_de
	# # lop_13_sr_sU3-dld42_de
	# # lop_13_sr_sU3-dld43_de
	# # # lop_13_sr_sU3-dld44_de
	# # # lop_13_sr_sU3-dld45_de
	# # # lop_13_sr_sU3-dld46_de
	# # # lop_13_sr_sU3-dld47_de
	# # lop_13_sr_sU3-dld48_de
	# # lop_13_sr_sU3-dld49_de
	# # lop_13_sr_sU3-dld50_de
	# # lop_13_sr_sU3-dld51_de
	# # # lop_13_sr_sU3-dld52_de
	# # # lop_13_sr_sU3-dld53_de
	# # # lop_13_sr_sU3-dld54_de
	# # lop_13_sr_sU3-dld55_de
	# # # lop_13_sr_sU3-dld56_de
	# # # lop_13_sr_sU3-dld57_de
	# # lop_13_sr_sU3-dld58_de
	# # # lop_13_sr_sU3-dld59_de
	# # # lop_13_sr_sU3-dld60_de
	# # # lop_13_sr_sU3-dld61_de
	# # # lop_13_sr_sU3-dld62_de
	# # # lop_13_sr_sU3-dld63_de
	# # # lop_13_sr_sU3-dld64_de
	# # # lop_13_sr_sU3-dld65_de
	# # # lop_13_sr_sU3-dld66_de
	# # lop_13_sr_sU3-dld67_de
	# # lop_13_sr_sU3-dld68_de
	# # # lop_13_sr_sU3-dld69_de
	# # # lop_13_sr_sU3-dld70_de
	# # # lop_13_sr_sU3-dld71_de
	# # # lop_13_sr_sU3-dld72_de
	# # lop_13_sr_sU3-dld73_de
	# # lop_13_sr_sU3-dld74_de
	# # lop_13_sr_sU3-dld75_de
	# #lop_13_sr_ls1_de
	# )

	run_codelets=(
		#     balanc_3_sr_de balanc_3_sr_sVS_de
		#     elmhes_10_sr_de elmhes_10_sr_sVS_de
		#     elmhes_11_sr_de
		#     elmhes_11_sr_sVS_de
		#     four1_2_sr_me
		#     hqr_15_sr_se
		hqr-sq_12_se
		hqr-sq_12_sVS_se
		#     lop_13_sr_de
		#     lop_13_sr_sVS_de
		#     ludcmp-sq_4_sr_se
		#     ludcmp-sq_4_sr_sVS_se
		#     matadd-flb_16_sr_de matadd-flb_16_sr_sVS_de
		#    mprove_8_sr_me
		#    mprove_8_sr_sVS_me
		#     mprove_9_sr_de mprove_9_sr_sVS_de
		#     ptr1_movaps_branch
		#     realft_4_sr_de
		relax2_26_sr_de
		relax2_26_sr_sVS_de
		#     rstrct_29_sr_de rstrct_29_sr_sVS_de
		s1244_sr_se
		s1244_sr_sVS_se
		#     s319_sr_se
		#     s319_sr_sVS_se
		#     svbksb_3_sr_se
		#     svbksb_3_sr_sVS_se
		#     svdcmp_11_sr_de svdcmp_11_sr_sVS_de
		#     svdcmp_13_sr_de svdcmp_13_sr_sVS_de
		#     svdcmp_14_sr_de svdcmp_14_sr_sVS_de
		#     svdcmp_6_de
		#     svdcmp_6_sVS_de
		toeplz_1_de
		toeplz_1_sVS_de
		#     toeplz_2_sr_de
		#     toeplz_4_sr_de
		#     tridag_1_sr_de
		#     tridag_2_sr_de
	)

	#GA set below
	# run_codelets=(
	# #  balanc_3_sr_de
	# #    balanc_3_sr_dx2
	# #    balanc_3_sr_sVS_dx2
	# #    elmhes_10_sr_dx2
	#     # elmhes_10_sr_sVS_dx2
	# #     elmhes_11_sr_dx2
	#     # elmhes_11_sr_sVS_dx2
	#     # four1_2_sr_mx2
	#     # hqr_15_sr_sx2
	#     # hqr-sq_12_sx2
	# #     hqr-sq_12_sVS_sx2
	#     # lop_13_sr_dx2
	#     # lop_13_sr_sVS_dx2
	#     # ludcmp-sq_4_sr_sx2
	#     # ludcmp-sq_4_sr_sVS_sx2
	#     # matadd-flb_16_sr_dx2
	#     # matadd-flb_16_sr_sVS_dx2
	#     # mprove_8_sr_mx2
	#     # mprove_8_sr_sVS_mx2
	#     # mprove_9_sr_dx2
	#     # mprove_9_sr_sVS_dx2
	#     # ptr1_vmovaps_branch
	#     # realft_4_sr_dx2
	#     # relax2_26_sr_dx2
	#     # relax2_26_sr_sVS_dx2
	#     # rstrct_29_sr_dx2
	#     # rstrct_29_sr_sVS_dx2
	#     # s1244_sr_sx2
	#     # s1244_sr_sVS_sx2
	#     # s319_sr_sx2
	#     # s319_sr_sVS_sx2
	#     # svbksb_3_sr_sx2
	#     # svbksb_3_sr_sVS_sx2
	#     # svdcmp_11_sr_dx2
	#     # svdcmp_11_sr_sVS_dx2
	#     # svdcmp_13_sr_dx2
	#     # svdcmp_13_sr_sVS_dx2
	#     # svdcmp_14_sr_dx2
	#     # svdcmp_14_sr_sVS_dx2
	#     # svdcmp_6_dx2
	# #     svdcmp_6_sVS_dx2
	#     # toeplz_1_dx2
	# #      toeplz_1_sVS_dx2
	#     # toeplz_2_sr_dx2
	#     # toeplz_4_sr_dx2
	#     # tridag_1_sr_dx2
	#     # tridag_2_sr_dx2
	#    # cg.c_main_line271_loop.c.0_dx2
	#    # cg.c_main_line271_loop.c.0_dx
	#    # cg.c_main_line271_loop.c.0_de
	#    # Crystal_div.c_Crystal_div_line65_loop.c.0_de
	#    # Crystal_div.c_Crystal_div_line65_loop.c.0_dx
	#    # Crystal_div.c_Crystal_div_line65_loop.c.0_dx2
	#    # sp.c_lhsy_line1028_loop.c.0_de
	#    # sp.c_lhsy_line1028_loop.c.0_dx
	#    # sp.c_lhsy_line1028_loop.c.0_dx2
	# #  sp.c_lhsx_line885_loop.c.0_sVS_dx2
	# #  sp.c_lhsx_line885_loop.c.0_dx3
	# #   bfs-load-preloaded_sVS_ig
	# #   bfs-load-preloaded-sort_sVS_ig
	# #   bfs-load-preloaded-nosub_sVS_ig
	# #   bfs-load-preloaded-sort-nosub_sVS_ig
	# #   bfs-load-preloaded-noaddsub_sVS_ig

	# #   bfs-load-preloaded-sort-noaddsub_sVS_ig
	# #    pr-sync-pull
	# #    bfs-pull-topo-sync_ix2

	#     bfs-push-data-sync_ix2
	#     bfs-push-data-async_ix2
	#     bfs-push-data-async-stldeq_ix2
	#     bfs-push-data-sync-fifo_ix2

	# #    bfs-pull-topo-async_ig
	# #    cc-pull-topo-async
	# #    cc-pull-topo-sync_ix2
	#     cc-uf-id_ix2
	#     cc-uf-topo-node_ix2
	#     pr-pull-topo-async
	# #    pr-pull-topo-sync_dx2
	# #    sssp-pull-topo-async
	# #    sssp-pull-topo-sync_ix2
	#     sssp-push-delta-sync_ix2
	#     sssp-push-delta-async_ix2
	# )

	# run_codelets=(
	# #   balanc_3_dx2
	#    balanc_3_sVS_dx2
	# #   elmhes_10_dx2
	#    elmhes_10_sVS_dx2
	# #   elmhes_11_dx2
	#    elmhes_11_sVS_dx2
	#    four1_2_mx2
	#    hqr_15_sx2
	# #   hqr-sq_12_sx2
	#    hqr-sq_12_sVS_sx2
	# #   lop_13_dx2
	#    lop_13_sVS_dx2
	# #   ludcmp-sq_4_sx2
	#    ludcmp-sq_4_sVS_sx2
	# #   matadd-flb_16_dx2
	#    matadd-flb_16_sVS_dx2
	# #   mprove_8_mx2
	#    mprove_8_sVS_mx2
	# #   mprove_9_dx2
	#    mprove_9_sVS_dx2
	#    ptr1_vmovaps_branch
	#    realft_4_dx2
	# #   relax2_26_dx2
	#    relax2_26_sVS_dx2
	# #   rstrct_29_dx2
	#    rstrct_29_sVS_dx2
	# #   s1244_sx2
	#    s1244_sVS_sx2
	# #   s319_sx2
	#    s319_sVS_sx2
	# #   svbksb_3_sx2
	#    svbksb_3_sVS_sx2
	# #   svdcmp_11_dx2
	#    svdcmp_11_sVS_dx2
	# #   svdcmp_13_dx2
	#    svdcmp_13_sVS_dx2
	# #   svdcmp_14_dx2
	#    svdcmp_14_sVS_dx2
	# #   svdcmp_6_dx2
	#    svdcmp_6_sVS_dx2
	# #   toeplz_1_dx2
	#    toeplz_1_sVS_dx2
	#    toeplz_2_dx2
	#    toeplz_4_dx2
	#    tridag_1_dx2
	#    tridag_2_dx2
	# )

	name2sizes[3mm93_orig.c_de]="9000"
	run_codelets=(
		3mm93_orig.c_de
		#    elmhes_11_de
		#    elmhes_11_sVS_de
		#     four1_2_me
		#    hqr_15_se
		#   hqr-sq_12_se
		#   hqr-sq_12_sVS_se
		#    lop_13_de
		#    lop_13_sVS_de
		#    ludcmp-sq_4_se
		#    ludcmp-sq_4_sVS_se
		#    matadd-flb_16_de
		#    matadd-flb_16_sVS_de
		#    mprove_8_me
		#    mprove_8_sVS_me
		#    mprove_9_de
		#    mprove_9_sVS_de
		#   ptr1_vmovaps_branch
		#     realft_4_de
		#    relax2_26_de
		#    relax2_26_sVS_de
		#    rstrct_29_de
		#    rstrct_29_sVS_de
		#    s1244_se
		#    s1244_sVS_se
		#    s319_se
		#    s319_sVS_se
		#    svbksb_3_se
		#    svbksb_3_sVS_se
		#    svdcmp_11_de
		#    svdcmp_11_sVS_de
		#    svdcmp_13_de
		#     svdcmp_13_sVS_de
		#    svdcmp_14_de
		#    svdcmp_14_sVS_de
		#   svdcmp_6_de
		#   svdcmp_6_sVS_de
		#   toeplz_1_de
		#   toeplz_1_sVS_de
		#    toeplz_2_de
		#    toeplz_4_de
		#    tridag_1_de
		#    tridag_2_de
	)

	# run_codelets=(
	# #  ptr1_movaps-1lfbhit_branch
	# #  ptr1_movaps-2lfbhit_branch
	# #  ptr1_movaps-3lfbhit_branch
	# #  ptr1_movaps-4lfbhit_branch
	# #  ptr1_movaps-5lfbhit_branch
	# #  ptr1_movaps-6lfbhit_branch
	# #  ptr1_movaps-7lfbhit_branch
	# #  ptr1_movaps-8lfbhit_branch
	# #  ptr1_movaps-9lfbhit_branch
	# #  ptr1_movaps-10lfbhit_branch
	# #  ptr1_movaps-11lfbhit_branch
	# #  ptr1_movaps-12lfbhit_branch
	# #  ptr1_movaps-13lfbhit_branch
	# #  ptr1_movaps-14lfbhit_branch
	# #  ptr1_movaps-15lfbhit_branch
	# #  ptr1_movaps-16lfbhit_branch
	# #  ptr1_movaps-17lfbhit_branch
	# #  ptr1_movaps-18lfbhit_branch
	# #  ptr1_movaps-19lfbhit_branch
	# #  ptr1_movaps-20lfbhit_branch
	# #  ptr1_movaps-21lfbhit_branch
	# #  ptr1_movaps-22lfbhit_branch
	# #  ptr1_movaps-23lfbhit_branch
	# #  ptr1_movaps-24lfbhit_branch
	# #  ptr1_movaps-25lfbhit_branch
	# #  ptr1_movaps-26lfbhit_branch
	# #  ptr1_movaps-27lfbhit_branch
	# #  ptr1_movaps-28lfbhit_branch
	# #  ptr1_movaps-29lfbhit_branch
	# #  ptr1_movaps-30lfbhit_branch
	# #  ptr1_movaps-31lfbhit_branch
	# #  ptr1_movaps-32lfbhit_branch

	# #  ptr2_movaps-1lfbhit_branch
	# #  ptr2_movaps-2lfbhit_branch
	# #  ptr2_movaps-3lfbhit_branch
	# #  ptr2_movaps-4lfbhit_branch
	# #  ptr2_movaps-5lfbhit_branch
	# #  ptr2_movaps-6lfbhit_branch
	# #  ptr2_movaps-7lfbhit_branch
	# #  ptr2_movaps-8lfbhit_branch
	# #  ptr2_movaps-9lfbhit_branch
	# #  ptr2_movaps-10lfbhit_branch
	# #  ptr2_movaps-11lfbhit_branch
	# #  ptr2_movaps-12lfbhit_branch
	# #  ptr2_movaps-13lfbhit_branch
	# #  ptr2_movaps-14lfbhit_branch
	# #  ptr2_movaps-15lfbhit_branch
	# #  ptr2_movaps-16lfbhit_branch
	# #  ptr2_movaps-17lfbhit_branch
	# #  ptr2_movaps-18lfbhit_branch
	# #  ptr2_movaps-19lfbhit_branch
	# #  ptr2_movaps-20lfbhit_branch
	# #  ptr2_movaps-21lfbhit_branch
	# #  ptr2_movaps-22lfbhit_branch

	# #  ptr2_movaps-23lfbhit_branch
	# #  ptr2_movaps-24lfbhit_branch
	# #  ptr2_movaps-25lfbhit_branch
	# #  ptr2_movaps-26lfbhit_branch

	# #  ptr2_movaps-27lfbhit_branch
	# #  ptr2_movaps-28lfbhit_branch
	# #  ptr2_movaps-29lfbhit_branch
	# #  ptr2_movaps-30lfbhit_branch
	# #  ptr2_movaps-31lfbhit_branch
	# #  ptr2_movaps-32lfbhit_branch
	# #  ptr2_movaps-33lfbhit_branch

	# #  ptr4_movaps-1lfbhit_branch
	# #  ptr4_movaps-2lfbhit_branch
	# #  ptr4_movaps-3lfbhit_branch
	# #  ptr4_movaps-4lfbhit_branch
	# #  ptr4_movaps-5lfbhit_branch
	# #  ptr4_movaps-6lfbhit_branch
	# #  ptr4_movaps-7lfbhit_branch
	# #  ptr4_movaps-8lfbhit_branch
	# #  ptr4_movaps-9lfbhit_branch

	# #  ptr1_movaps_branch
	# #  ptr2_movaps_branch
	# #  ptr3_movaps_branch
	# #  ptr4_movaps_branch
	# #  ptr5_movaps_branch
	# #  ptr6_movaps_branch
	# #  ptr7_movaps_branch
	# #  ptr8_movaps_branch
	# #  ptr9_movaps_branch
	# #  ptr10_movaps_branch
	# #  ptr11_movaps_branch

	# # #  ptr1_movaps-2rip_branch
	# # #  ptr2_movaps-2rip_branch
	# # #  ptr3_movaps-2rip_branch
	# # #  ptr4_movaps-2rip_branch
	# # #  ptr5_movaps-2rip_branch
	# # #  ptr6_movaps-2rip_branch
	# # #  ptr7_movaps-2rip_branch
	# # #  ptr8_movaps-2rip_branch
	# # #  ptr9_movaps-2rip_branch
	# # #  ptr10_movaps-2rip_branch
	# # #  ptr11_movaps-2rip_branch


	# ptr1_vmovaps-1lfbhit_branch
	# ptr1_vmovaps-2lfbhit_branch
	# ptr1_vmovaps-3lfbhit_branch
	# ptr1_vmovaps-4lfbhit_branch
	# ptr1_vmovaps-5lfbhit_branch
	# ptr1_vmovaps-6lfbhit_branch
	# ptr1_vmovaps-7lfbhit_branch
	# ptr1_vmovaps-8lfbhit_branch
	# ptr1_vmovaps-9lfbhit_branch
	# ptr1_vmovaps-10lfbhit_branch
	# ptr1_vmovaps-11lfbhit_branch
	# ptr1_vmovaps-12lfbhit_branch
	# ptr1_vmovaps-13lfbhit_branch
	# ptr1_vmovaps-14lfbhit_branch
	# ptr1_vmovaps-15lfbhit_branch
	# ptr1_vmovaps-16lfbhit_branch
	# ptr1_vmovaps-17lfbhit_branch
	# ptr1_vmovaps-18lfbhit_branch
	# ptr1_vmovaps-19lfbhit_branch
	# ptr1_vmovaps-20lfbhit_branch
	# ptr1_vmovaps-21lfbhit_branch
	# ptr1_vmovaps-22lfbhit_branch
	# ptr1_vmovaps-23lfbhit_branch
	# ptr1_vmovaps-24lfbhit_branch
	# ptr1_vmovaps-25lfbhit_branch
	# ptr1_vmovaps-26lfbhit_branch
	# ptr1_vmovaps-27lfbhit_branch
	# ptr1_vmovaps-28lfbhit_branch
	# ptr1_vmovaps-29lfbhit_branch
	# ptr1_vmovaps-30lfbhit_branch
	# ptr1_vmovaps-31lfbhit_branch
	# ptr1_vmovaps-32lfbhit_branch

	# ptr2_vmovaps-1lfbhit_branch
	# ptr2_vmovaps-2lfbhit_branch
	# ptr2_vmovaps-3lfbhit_branch
	# ptr2_vmovaps-4lfbhit_branch
	# ptr2_vmovaps-5lfbhit_branch
	# ptr2_vmovaps-6lfbhit_branch
	# ptr2_vmovaps-7lfbhit_branch
	# ptr2_vmovaps-8lfbhit_branch
	# ptr2_vmovaps-9lfbhit_branch
	# ptr2_vmovaps-10lfbhit_branch
	# ptr2_vmovaps-11lfbhit_branch
	# ptr2_vmovaps-12lfbhit_branch
	# ptr2_vmovaps-13lfbhit_branch
	# ptr2_vmovaps-14lfbhit_branch
	# ptr2_vmovaps-15lfbhit_branch
	# ptr2_vmovaps-16lfbhit_branch
	# ptr2_vmovaps-17lfbhit_branch
	# ptr2_vmovaps-18lfbhit_branch
	# ptr2_vmovaps-19lfbhit_branch
	# ptr2_vmovaps-20lfbhit_branch
	# ptr2_vmovaps-21lfbhit_branch
	# ptr2_vmovaps-22lfbhit_branch

	# ptr2_vmovaps-23lfbhit_branch
	# ptr2_vmovaps-24lfbhit_branch
	# ptr2_vmovaps-25lfbhit_branch
	# ptr2_vmovaps-26lfbhit_branch

	# ptr2_vmovaps-27lfbhit_branch
	# ptr2_vmovaps-28lfbhit_branch
	# ptr2_vmovaps-29lfbhit_branch
	# ptr2_vmovaps-30lfbhit_branch
	# ptr2_vmovaps-31lfbhit_branch
	# ptr2_vmovaps-32lfbhit_branch
	# ptr2_vmovaps-33lfbhit_branch

	# ptr4_vmovaps-1lfbhit_branch
	# ptr4_vmovaps-2lfbhit_branch
	# ptr4_vmovaps-3lfbhit_branch
	# ptr4_vmovaps-4lfbhit_branch
	# ptr4_vmovaps-5lfbhit_branch
	# ptr4_vmovaps-6lfbhit_branch
	# ptr4_vmovaps-7lfbhit_branch
	# ptr4_vmovaps-8lfbhit_branch
	# ptr4_vmovaps-9lfbhit_branch

	# ptr1_vmovaps_branch
	# ptr2_vmovaps_branch
	# ptr3_vmovaps_branch
	# ptr4_vmovaps_branch
	# ptr5_vmovaps_branch
	# ptr6_vmovaps_branch
	# ptr7_vmovaps_branch
	# ptr8_vmovaps_branch
	# ptr9_vmovaps_branch
	# ptr10_vmovaps_branch
	# ptr11_vmovaps_branch
	# )

	# name2sizes[ludcmp-sq_4_sr_se]="9000"
	# name2sizes[elmhes_11_sr_de]="4000000"
	# name2sizes[balanc_3_sr_de]="80000000"
	# name2sizes[hqr_15_sr_se]="30000"

	# # #Testing
	# run_codelets=(
	# # # # ptr1_movaps-1lfbhit_branch
	# # #  ptr1_movaps_branch
	# # #  ludcmp-sq_4_sr_se
	# # #  elmhes_11_sr_de
	# # #  balanc_3_sr_de
	# # # hqr_15_sr_se
	# #  ptr9_movaps_branch

	#      hqr_15_sr_se
	# #     lop_13_sr_sVS_de
	# #     lop_13_sr_de
	# #     mprove_8_sr_me
	# #     mprove_8_sr_sVS_me
	# #     rstrct_29_sr_sVS_de
	# #     rstrct_29_sr_de
	# #    svbksb_3_sr_se
	# #    svbksb_3_sr_sVS_se

	# )


	# Overriden above defn
	# name2sizes[hqr-sq_12_se]="96"
	# name2sizes[hqr-sq_12_sVS_se]="96"
	# # name2sizes[hqr-1d_12_se]="295936"
	# # name2sizes[hqr-1d_12_sVS_se]="295936"
	# name2sizes[hqr-1d_12_fp-w-rip-sVS_se]="295936"
	# name2sizes[hqr-1d_12_fp-no-rip-sVS_se]="295936"

	# #name2sizes[hqr-1d_12_ls-sVS_se]="295936"
	# name2sizes[hqr-1d_12_ls-sVS_se]="1000 10000"
	# name2sizes[hqr-1d_12_no-andps-sVS_se]="295936"
	# name2sizes[hqr-1d_12_no-red-sVS_se]="295936"
	# name2sizes[hqr-1d_12_no-rip-sVS_se]="295936"
	# name2sizes[hqr-1d_12_sU8-sVS_se]="295936"
	# #name2sizes[hqr-1ds64_12_sVS_se]="295936"
	# name2sizes[hqr-1ds64_12_sVS_se]="1000 10000"
	# #name2sizes[hqr-1ds64_12_ls-sVS_se]="1000 10000 295936"
	# name2sizes[hqr-1ds64_12_ls-sVS_se]="64000 640000 18939904"
	# name2sizes[hqr-1d_12_ls_se]="295936"
	# name2sizes[hqr-1d_12_ls-no-rip_se]="295936"


	#name2sizes[hqr-sq_12_se]="30 240"
	#name2sizes[hqr-sq_12_sVS_se]="30 240"



	name2sizes[hqr-1d_12_se]="1000 10000"
	name2sizes[hqr-1d_12_sVS_se]="1000 10000"

	#name2sizes[hqr-sq-no-tail_12_se]="240 500 550 600"
	#name2sizes[hqr-sq-no-tail_12_sVS_se]="240 500 550 600"
	name2sizes[hqr-sq-no-tail_12_se]="800 1000 1200 1400 1600 1800 2000 2200 2400 2600 2800 3000 3200 3400 3600 3800 4000"
	name2sizes[hqr-sq-no-tail_12_sVS_se]="800 1000 1200 1400 1600 1800 2000 2200 2400 2600 2800 3000 3200 3400 3600 3800 4000"







	name2sizes[balanc_3_de]="8000"
	name2sizes[balanc_3_sVS_de]="80000000"
	name2sizes[elmhes_10_de]="80000000"
	name2sizes[elmhes_10_sVS_de]="80000000"
	name2sizes[elmhes_11_de]="4000000"
	name2sizes[elmhes_11_sVS_de]="4000000"
	name2sizes[four1_2_me]="80000000"
	name2sizes[hqr_15_se]="50000"
	name2sizes[hqr-sq_12_se]="9024"
	name2sizes[hqr-sq_12_sVS_se]="9024"
	name2sizes[lop_13_de]="13514"
	name2sizes[lop_13_sVS_de]="13514"
	name2sizes[ludcmp-sq_4_se]="9000"
	name2sizes[ludcmp-sq_4_sVS_se]="9000"
	name2sizes[matadd-flb_16_de]="9000"
	name2sizes[matadd-flb_16_sVS_de]="9000"
	name2sizes[mprove_8_me]="13500"
	name2sizes[mprove_8_sVS_me]="13500"
	name2sizes[mprove_9_de]="80000000"
	name2sizes[mprove_9_sVS_de]="80000000"
	name2sizes[ptr1_movaps_branch]="4000000"
	name2sizes[realft_4_de]="80000000"
	name2sizes[relax2_26_de]="9002"
	name2sizes[relax2_26_sVS_de]="9002"
	name2sizes[rstrct_29_de]="27011"
	name2sizes[rstrct_29_sVS_de]="27011"
	name2sizes[s1244_se]="80000001"
	name2sizes[s1244_sVS_se]="80000001"
	name2sizes[s319_se]="80000000"
	name2sizes[s319_sVS_se]="80000000"
	name2sizes[svbksb_3_se]="12000"
	name2sizes[svbksb_3_sVS_se]="12000"
	name2sizes[svdcmp_11_de]="4000000"
	name2sizes[svdcmp_11_sVS_de]="4000000"
	name2sizes[svdcmp_13_de]="80000000"
	name2sizes[svdcmp_13_sVS_de]="80000000"
	name2sizes[svdcmp_14_de]="80000000"
	name2sizes[svdcmp_14_sVS_de]="80000000"
	name2sizes[svdcmp_6_de]="4000000"
	name2sizes[svdcmp_6_sVS_de]="4000000"
	name2sizes[toeplz_1_de]="80000001"
	name2sizes[toeplz_1_sVS_de]="80000001"
	name2sizes[toeplz_2_de]="80000000"
	name2sizes[toeplz_4_de]="80000000"
	name2sizes[tridag_1_de]="8000000"
	name2sizes[tridag_2_de]="80000000"






	#name2sizes[ptr_ld_branch]="10000"
	#name2sizes[loads_1Sx4-movsd]="200000"

	#runLoop "${runId}" "$variants" "$memory_loads" "$frequencies"  "$num_cores" "$prefetchers" "RESOURCE=0,SQ=0,SQ_HISTOGRAM=0,LFB_HISTOGRAM=0,TOPDOWN=0,LFB=0,MEM_ROWBUFF=0,MEM_TRAFFIC=0,MEM_HIT=0,TLB=0,LSD=0"
	# Could be shorten by exporting the variables instead
	runId="${runId}" variants="$variants" memory_loads="$memory_loads" frequencies="$frequencies"  num_cores="$num_cores" prefetchers="$prefetchers" counter_list_override="RESOURCE=1,SQ=0,SQ_HISTOGRAM=0,LFB_HISTOGRAM=0,TOPDOWN=0,LFB=0,MEM_ROWBUFF=0,MEM_TRAFFIC=1,MEM_HIT=0,TLB=0,LSD=0" runLoop



	return

	set -o pipefail # make sure pipe of tee would not reset return code.


	echo RUN codelets : ${run_codelets[@]}

	for codelet in ${run_codelets[@]}
	do
		codelet_path=${name2path[${codelet}]}
		sizes=${name2sizes[${codelet}]}
		#  echo ${codelet_path}
		#  ls ${codelet_path}
		#  echo "SS: ${sizes}"

		echo "Launching CLS on $codelet_path...for sizes $sizes"

		${LOGGER_SH} ${runId} "Launching CLS on '$codelet_path'..."

		./cls.sh "$codelet_path" "$variants" "${sizes}" "$memory_loads" "$frequencies"  "${runId}" | tee "$codelet_path/cls.log"
		res=$?
		if [[ "$res" != "0" ]]
		then
			#      echo -e "\tAn error occured! Check '$codelet_path/cls.log' for more information."
			${LOGGER_SH} ${runId} "FAILED: Check '${codelet_path}/cls.log' for more information."
		fi
	done


	# exit



	# ### Added above

	# for codelet in $linear_codelets
	# do
	# 	${LOGGER_SH} ${runId} "Launching CLS on '$codelet'..."
	# 	./cls.sh "$codelet" "$variants" "$linear_sizes" "$memory_loads" "$frequencies"  "${runId}" | tee "$codelet/cls.log"
	# 	#./cls_get_metrics.sh "$codelet" "$variants" "$linear_sizes" "$memory_loads" "$frequencies" "${runId}" | tee "$codelet/cls.log"
	# 	# &> "$codelet/cls.log"
	# 	res=$?
	# 	if [[ "$res" != "0" ]]
	# 	then
	# 		echo -e "\tAn error occured! Check '$codelet/cls.log' for more information."
	# 	fi
	# done

	# for codelet in $quadratic_codelets
	# do
	# 	${LOGGER_SH} ${runId} "Launching CLS on '$codelet'..."
	# 	./cls.sh "$codelet" "$variants" "$quadratic_sizes" "$memory_loads" "$frequencies" "${runId}" | tee "$codelet/cls.log"
	# 	# &> "$codelet/cls.log"
	# 	res=$?
	# 	if [[ "$res" != "0" ]]
	# 	then
	# 		echo -e "\tAn error occured! Check '$codelet/cls.log' for more information."
	# 	fi
	# done
	# for codelet in $ptr_codelets
	# do
	# 	${LOGGER_SH} ${runId} "Launching CLS on '$codelet'..."
	# 	./cls.sh "$codelet" "$variants" "$ubmk_sizes" "$memory_loads" "$frequencies"  "${runId}" | tee "$codelet/cls.log"
	# 	# &> "$codelet/cls.log"
	# 	res=$?
	# 	if [[ "$res" != "0" ]]
	# 	then
	# 		echo -e "\tAn error occured! Check '$codelet/cls.log' for more information."
	# 	fi
	# done


}

launchIt $0 run "$@"


#END_VRUN_SH=$(date '+%s')
#ELAPSED_VRUN_SH=$((${END_VRUN_SH} - ${START_VRUN_SH}))

#${LOGGER_SH} ${START_VRUN_SH} "$0 finished in $(${SEC_TO_DHMS_SH} ${ELAPSED_VRUN_SH}) at $(date --date=@${END_VRUN_SH})"
