
' ====================================================
' Section 0 - Part 1 Importing Data from Centralized Database
' ====================================================

' This file will import both quarterly and monthly data from Excel database to respective EViews pagefiles. 
' The Pagefile will be constructed based on the frequency of original data. 

' Overview of this section: 
' --------------------------------
' Step 0. Basic Setup 
' Step 1, Input Excel File Details
' Step 2. Import Monthly Data
' Step 3. Import Quarterly Data
' Step 4. Seasonally Adjust RGDP
' Step 5. Save workfile 

' =========================================
' ========== INPUT 0: BASIC SETUP ============
' =========================================

' Set up the running mode: Quiet vs. Verbose
' Quiet (Fast): No screen or status line updates 
' Verbose (Slow): Update screen and status line
MODE QUIET

' Close all the windows once run this file. This will make your EViews work area clean
CLOSE @ALL

' Set up the default path to the runpath (the path that you saved this program file)
%path = @runpath

cd %path 

' =========================================
' ===== INPUT 1: INPUT EXCEL FILE DETAIL=======
' =========================================

' 1. Enter the file name of the Excel file (stored in the same folder as this program): 
' ------------------------------------------------------------------------------------------------
%excel = "India"

' 2. Enter the name of two Source Excel Sheets: 
' -------------------------------------------------------------------------------------------------
' Monthly Sheet Name:
%sheet_m = "Monthly"

' Quarterly Sheet Name:
%sheet_q = "Quarterly"

' 3. Enter the start and end date of the range: 
' --------------------------------------------------------------------------------------------------
' Monthly: 
%start_date_m = "1999M01"
%end_date_m = "2023M12" 

' Quarterly: 
%start_date_q = "1999Q1"
%end_date_q = "2023Q4" 


' =========================================
' ===== INPUT 2: IMPORT MONTHLY DATA ========
' =========================================

'Open Excel & Create EViews workfile

wfopen {%excel}.xlsx range={%sheet_m} byrow colhead=15 namepos=firstatt na="#N/A" names=("Date",,,,,,,,,,,,,,,,,,,) @freq M @id @date(Date) @destid @date @smpl @all

wfdetails

'Rename Workfile to "Monthly" (to distinguish from different frequency) 
pagerename {%excel} Monthly_FromExcel 

' set up the page range 
pagestruct(start = {%start_date_m}, end = {%end_date_m}) 

' Show detail of workfile
wfdetails 

' =========================================
' ===== INPUT 3: IMPORT QUARTERLY DATA ======
' =========================================

'Create a new page in quarterly frequency, using the range setup earlier
pagecreate(page=Quarterly_FromExcel) q {%start_date_q} {%end_date_q} 

'Import data from the Excel to the quarterly pagefile just created 
import {%excel}.xlsx range={%sheet_q} byrow colhead=15 namepos=firstatt na="#N/A" names=("Date",,,) @freq Q @id @date(date) @smpl @all

wfdetails

' set up the page range 

pagestruct(start = {%start_date_q}, end = {%end_date_q}) 

pageselect Quarterly_FromExcel

' Show detail of workfile

wfdetails 

' Rename real GDP 
smpl @all 

rename rgdp_sa rgdp

' ===========================
' ===== INPUT 4: GRAPHS ======
' ===========================
pageselect Quarterly_FromExcel

pagecopy(page=Misc)

' For RGDP in growth rate 
genr rgdp_growth = log(rgdp) - log(rgdp(-4)) 

rgdp_growth.hpf

group grp01_rgdp_g rgdp_growth hptrend01

freeze(graph01_rgdp_g) grp01_rgdp_g.line

' For RGDP in level 
rgdp.hpf

group grp02_rgdp rgdp hptrend02

freeze(graph02_rgdp) grp02_rgdp.line

' ============================================
' ========== STEP 4. SAVE WORKFILE =============
' ============================================ 

wfsave nwc.wf1


