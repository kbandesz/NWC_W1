# AGENTS.md

## 1. Project overview
This project aims to replicate an Eviews workshop in a Google Colab notebook. The workshop teaches students the theory of basic nowcasting methods and demonstrates their practical implementation through a country case study.

## 2. Repository structure
- `W-1 Standard Nowcasting (Bridge, MIDAS, U-MIDAS)/India.xlsx`: input data for the nowcasting methods
- `W-1 Standard Nowcasting (Bridge, MIDAS, U-MIDAS)/0_part_1_import_india.prg`: Eviews program for importing the raw data from Excel
- `W-1 Standard Nowcasting (Bridge, MIDAS, U-MIDAS)/ 1_data_cleaning.prg`: Eviews program for seasonal adjustment, data transformation, and cleaning
- `W-1 Standard Nowcasting (Bridge, MIDAS, U-MIDAS)/2_bridge_basic.prg`: Eviews program for Nowcasting with a Bridge equation
- `W-1 Standard Nowcasting (Bridge, MIDAS, U-MIDAS)/ 3_midas_basic.prg`: Eviews program for nowcasting with MIDAS and U-MIDAS models
- `W-1 Standard Nowcasting (Bridge, MIDAS, U-MIDAS)/[Workbook] W-1 Standard Nowcasting.pdf`: The description of the workshop with detailed point-and-click guidance for the Eviews workshop. Includes a lot of screenshots.
- `NWC_W1_notebook.ipynb`: Colab Python notebook that reproduces the data management and econometric estimation procedures from the Eviews Programs. It also includes the background information from the pdf file.

## Notebook Workflow
- The first and last cells manage the link between GitHub and the local clone of the repository on my Google Drive. These do not have a role in the Nowcasting workshop. Do NOT edit them. Do NOT run them when testing the code. Treat them is non-existent for your purposes.
- The notebook downloads a zip file from my Google Drive that includes `India.xlsx' (data file) and `x13as_ascii` (X13 seasonal adjustment routine for Linux). This ensures that the notebook can be run without any additional files.
- After data loading and transformations the notebook estimates nowcasting models (Bridge, Midas, U-Midas), and evaluates them out-of-sample

## 7. Objective and rules
- The goal is to replicate closely the techniques and numerical results documented in the workshop guide (pdf) and the Eview programs (*.prg)
- Small numerical deviations are allowed if reproducing the exact econometric estimators with the same hyperparameters in not possible or leads to complicated in Python code
- It is important to keep the Python code as simple as possible. This notebook is for educational purposes, not for production code.
- The text cells should contain useful information and guidance for students to understand the basic theoretical underpinnings of the techniques.
