# AR2
EEG artifact reduction software

Written by Shennan Aibel Weiss MD, PhD 2016
GNU v3 Public License, Provisional Patent US/62297202
University of California Los Angeles

Software written in Matlab 2014b 

Required Software For Use
CUDAICA 
https://github.com/fraimondo/cudaica
requirements are provided by the author

BlockEDFload and write
https://www.mathworks.com/matlabcentral/fileexchange/42784-blockedfload
https://www.mathworks.com/matlabcentral/fileexchange/46339-blockedfwrite

After installing these programs and adding each to the Matlab path. Be sure to correct the path definitions in cudaica.m

To execute AR2 please use the EEG data available at https://zenodo.org/record/221095#.WGBIj7YrLdQ stored in European Data Format (EDF)
as the input file.

[eeg] = cudaica_scalp_v4('input_eeg.edf','scalp_input_matrix.mat','ar2_eeg.edf');

The original and AR2 processed EDF files can be inspected using most EDF viewers or Persyst (TM).

The code can easily be adapted for EDF files exported from EEG equipment manufacturers such as Nihon Kohden (TM).

File Inventory
1) cudaica_matlab_scalp_v2.m: Calls CUDAICA and performs AR2 calculations
2) cudaica_scalp_v4 nk.m: AR2 main function for importing NK scalp EEG data
3) cudaica_scalp_v4.m: AR2 main function for importing Zenmodo scalp EEG data
4) cudaica_trialfun.m: module for abnormal impedance detection (requires field trip)
5) cudaicascalp.m: Calls CUDAICA and performs AR2 calculations
6) eeg_checkset.m: EEGlab function
7) eeg_filter.m: 500th order FIR symmetric filter
8) eeg_getdatact.m: EEGlab function
9) find_badchannels_scalp.m
10) finputcheck.m: EEGlab function
11) floatread.m: EEGlab function
12) floatwrite.m: EEGlab function
13) histogram2.m: module for abnormal impedance detection
14) information.m: module for abnormal impedance detection
15) loadmodout12.m: EEGlab function
16) matrixreader.m: function for channel directory import 
17) mutualinformation_norm_strehl_ghosh1.m: module for abnormal impedance detection
18) pop_editset.m: EEGlab function
19) pop_importdata.m: EEGlab function
20) pop_subcomp.m: EEGlab function
21) scalp_input_matrix.mat: Channel directory for example data (Zenmodo) import. Cell Array
22) scalp_input_matrix_nk.mat: Channel directory for NK scalp EEG data import. Cell Array
23) setdiff_bc.m: EEGlab function: 
24) signalHeader_correctlabels_39.mat: stored data file for NK scalp EEG data import and export
25) signalHeader_correctlabels_41.mat: stored data file for NK scalp EEG data import and export
26) signalHeader_correctlabels_43.mat: stored data file for NK scalp EEG data import and export

