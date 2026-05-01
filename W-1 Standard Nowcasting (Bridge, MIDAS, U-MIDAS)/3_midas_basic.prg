'=================================
'===== 0. Preamble ==================
'=================================
MODE QUIET

CLOSE @ALL

%path = @runpath

cd %path

wfopen nwc_2_bridge.wf1

if @pageexist("Midas") then	 
	pagedelete Midas
endif

pageselect Bridge

pagecopy(page=Midas)

pageselect Midas

copy(overwrite) Bridge\eq0*_f_*

' Note that HF is already extended to end-quarter after running Bridge
' As a result, no need to extend in subsequent scripts

'=================================
'====MIDAS - Estimating equation ========
'=================================
'string rep_baseline_q = @wdrop(rep_baseline,base_m)

' Set sample for estimation
smpl sample_for_estimation

' MIdas equation
equation eq02_f_midas.midas(maxlag=12, lag=auto, midwgt=almon, tag=auto) DLOG(RGDP) DLOG(RGDP(-3)) DLOG(RGDP(-2)) DLOG(RGDP(-1)) DLOG(RGDP_US(-1)) DLOG(RGDP_CN(-1)) CRISIS C @ monthly\DLOG(CONSU_MOTOR) monthly\D(PMI_NEW)

'==================================
'=== MIDAS - Calculate nowcast equation====
'=================================
' Calculate Nowcast
smpl smpl_for_nowcast
eq02_f_midas.forecast(e,g,ga) nowcast_rgdp_midas

' Calculate in-sample forecast for evaluation
smpl smpl_for_evaluation
freeze(mode=overwrite, midas_static) eq02_f_midas.fit(e,g,ga) rgdp_f_midas


'=================================
'====U-MIDAS - Estimating equation ========
'=================================
'string rep_baseline_q = @wdrop(rep_baseline,base_m)

' Set sample for estimation
smpl sample_for_estimation

' U-MIDAS equation
equation eq03_f_umidas.midas(midwgt=umidas, fixedlag=3)  DLOG(RGDP) DLOG(RGDP(-3)) DLOG(RGDP(-2)) DLOG(RGDP(-1)) DLOG(RGDP_US(-1)) DLOG(RGDP_CN(-1)) CRISIS C @ monthly\DLOG(CONSU_MOTOR) monthly\D(PMI_NEW)


'==================================
'=== U-MIDAS - Calculate nowcast equation====
'=================================
' Calculate Nowcast
smpl smpl_for_nowcast
eq03_f_umidas.forecast(e,g,ga) nowcast_rgdp_umidas

' Calculate in-sample forecast for evaluation
smpl smpl_for_evaluation
freeze(mode=overwrite, umidas_static) eq03_f_umidas.fit(e,g,ga) rgdp_f_umidas

wfsave(2) nwc_3_midas.wf1
wfsave(2) nwc.wf1


