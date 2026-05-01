'===============================
'====== Data Cleaning =============
'===============================

'Step 1: Create page file
'Step 2: Create additional variables
'Step 3: Perform seasonal adjustment
'Step 4: Define useful objects

'=================================
'===== 0. Preamble ==================
'=================================
MODE QUIET 'Set up running Model
CLOSE @ALL ' Close windows

%path = @runpath ' Set up the default path to the runpath
cd %path

'=================================
'===== 1. Create Page file =============
'=================================
wfopen nwc.wf1

if @pageexist("Monthly") then
	 
	pagedelete Monthly

endif

pageselect Monthly_FromExcel
' Create Monthly Page with necessary variables
pagecopy(page=Monthly, wf=NWC) CONSU_MOTOR PMI_NEW

if @pageexist("Quarterly") then
	 
	pagedelete Quarterly

endif

pageselect Quarterly_FromExcel

pagecopy(page=Quarterly)

'=================================
'===== 2. Create Variables =============
'=================================
' In this section, you may set up the dummy variable as needed. 
' A "CRISIS" dummy variable has been set up as an example. 
' Same procedure can apply to other dummy variable as well. 

pageselect Quarterly

' Set sample to include all observations
smpl @all 

' Create a new variable and set value = 0 for all periods
genr crisis = 0 

' Enter the specific date, and set value = 1 for those date 

' 1) Financial Crisis 
smpl 2009Q1 2009Q1 ' Financial Crisis
crisis = 1 

' 2) 2016 Demonetization 
smpl 2016Q4 2016Q4 ' 2016 Demonetization (Nov 8, 2016 ~ Dec 30, 2016)
crisis = 1 

' 3) COVID-19 
smpl 2020Q2 2020Q2 ' COVID-19 First Wave
crisis = 1
smpl 2021Q2 2021Q2 ' COVID-19 Second Wave
crisis = 1

' Set sample size back to all observation 
smpl @all 

'=================================
'===== 3. Create Variables =============
'=================================
pageselect Monthly ' Monthly page

' list of variables to seasonally adjusted
' note that PMI_NEW is already seasonally adjusted
string to_sa = "consu_motor"

for %var {to_sa}  
		
' Initiate X-13 Seasonal adjustment procedures, with default settings 
			'{%var}.x13(save="d11")  @x11arima(amdl=b)  @x11()
		{%var}.x13(save="d11", tf=auto, outtype="tc", outspan="2020.1 , 2021.4")  @x11arima(amdl=b) @reg(regs="const") @x11()
							
rename {%var} {%var}_u 'rename with _u (unadjusted)
rename {%var}_d11 {%var} 'rename d11 without _

next

'=================================
'===== 4. Define Useful Objects =========
'=================================
'Define string in both frequencies

for %page Quarterly Monthly 

pageselect {%page}

'4.1) Enter the estimation start and end date (for regression)
' -----------------------------------------------------------
' ========= Starting Date ===========
' Enter the estimation sample start date 
string estimation_start = "2000Q1" 

' Enter the estimation start date in month (for monthly realistic foecast evaluation). Note: this should be the starting month of your estimation start 
string estimation_start_m = "2000M01" 

' ========= Ending Date ===========
' Enter the estimation sample end date
string estimation_end = "2023Q1" 

' Enter the estimation end date in month (for monthly realistic foecast evaluation). Note: this should be the ending month of your estimation start 
string estimation_end_m = "2023M03" 

sample sample_for_estimation.set {estimation_start} {estimation_end}

' 4.2) Enter the nowcast period 
' -----------------------------------------------------------
' Enter the target nowcast period starting point 
string nowcast_start = "2023Q2" 

' Enter the target nowcast period ending point 
string nowcast_end = "2023Q2" 

' this should be the monthly equivalent of the "nowcast_end", should be the ending month of your target nowcast quarterly period
string nowcast_target_m = "2023M06"

' Set up Nowcast period
sample smpl_for_nowcast.set {nowcast_start} {nowcast_end} 

' 4.3) Enter the evaluation period
' -----------------------------------------------------------
' Enter the evaluation start period (to evaluate the accuracy of the nowcasting model, in-sample evaluation)
string nowcast_eval_start = "2018Q1" 

' Enter the evaluation start in monthly equivalent, in starting month of the quarter
string nowcast_eval_start_m = "2018M01" 

' Set up Sample for evaluation 
sample smpl_for_evaluation.set {nowcast_eval_start} {estimation_end}

next
'=================================
'===== Optional: Estimate Base Model =====
'=================================
smpl @all

pageselect quarterly

' Copy variables needed for the base model
copy(c=sn) Monthly\CONSU_MOTOR *
copy(c=an) Monthly\PMI_NEW *


smpl {estimation_start} {estimation_end}-1

' generate the baseline model using the target variable, lagged dependent variable, dummy, and high-frequency indicators 
equation eq_f_base.ls DLOG(RGDP) DLOG(RGDP(-3)) DLOG(RGDP(-2)) DLOG(RGDP(-1)) DLOG(CONSU_MOTOR) D(PMI_NEW) DLOG(RGDP_US(-1)) DLOG(RGDP_CN(-1)) CRISIS C

smpl {estimation_end} {estimation_end}

eq_f_base.forecast(e, g, ga) rgdp_f_{estimation_end} @se rgdp_f_{estimation_end}_se

' Save workfile
wfsave nwc.wf1
wfsave nwc_1_clean.wf1


