'=================================
'===== 0. Preamble ==================
'=================================

MODE QUIET
CLOSE @ALL

%path = @runpath

cd %path

wfopen nwc_1_clean.wf1

if @pageexist("Bridge") then	 
	pagedelete Bridge
endif

' if there is a variable with suffix _o, delete (otherwise cannot forecast till end-Q)
' that means Bridge program was already run

pageselect monthly

if @isobject("consu_motor_o") then
	delete consu_motor
	rename consu_motor_o consu_motor
endif

if @isobject("pmi_new_o") then
	delete pmi_new
	rename pmi_new_o pmi_new
endif

' Create a new Bridge page based on "Quarterly"
pageselect quarterly
pagecopy(page=Bridge)

'=================================
'==== Step1: Estimate a Bridge Equation ===
'================================

' Set sample for estimation
smpl sample_for_estimation

' Bridge Equation
equation eq01_f_bridge.ls DLOG(RGDP) DLOG(RGDP(-3)) DLOG(RGDP(-2)) DLOG(RGDP(-1)) DLOG(CONSU_MOTOR) D(PMI_NEW) DLOG(RGDP_US(-1)) DLOG(RGDP_CN(-1)) CRISIS C


'=====================================
'==== Step2: Filling HF indicator to end-quarter ===
'=====================================
' Fill it using Autoarma (Box-Jenkins)


pageselect Monthly

for %var CONSU_MOTOR PMI_NEW

string last_{%var} = {%var}.@last ' last available period
rename {%var} {%var}_o '_o for original

'Automatic ARIMA
smpl @first {last_{%var}}

{%var}_o.autoarma(tform=auto, forclen={nowcast_target_m}, eqname=arma_{%var}) {%var} c

next

'==================================
'=== Step 3: Convert HF to LF ===========
'=================================

pageselect bridge
' Copy monthly indicator to quarterly (Bridge pagE)
copy(c=sn) Monthly\CONSU_MOTOR * 'sum (missing=NA)
copy(c=an) Monthly\PMI_NEW * 'average (missing = NA)


'==================================
'=== Step 4: Nowcast using Bridge model ====
'=================================

' Calculate Nowcast
smpl smpl_for_nowcast
eq01_f_bridge.forecast(e, g, ga) nowcast_rgdp_bridge

' Calculate in-sample forecast for evaluation
smpl smpl_for_evaluation

freeze(mode=overwrite, bridge_static) eq01_f_bridge.fit(e, g, ga) rgdp_f_bridge

' Save workfile
wfsave(2) nwc.wf1
wfsave(2) nwc_2_bridge.wf1


