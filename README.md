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
cudaica_matlab_scalp_v2.m:
cudaica_scalp_v4 nk.m
cudaica_scalp_v4.m
cudaica_trialfun.m
cudaicascalp.m
eeg_checkset.m: EEGlab function
eeg_filter.m: 500th order FIR symmetric filter
eeg_getdatact.m: EEGlab function
find_badchannels_scalp.m
finputcheck.m: EEGlab function
floatread.m: EEGlab function
floatwrite.m: EEGlab function
histogram2.m: module for abnormal impedance detection
information.m: module for abnormal impedance detection
loadmodout12.m: EEGlab function
matrixreader.m: function for channel directory import 
mutualinformation_norm_strehl_ghosh1.m: module for abnormal impedance detection
pop_editset.m: EEGlab function
pop_importdata.m: EEGlab function
pop_subcomp.m: EEGlab function
scalp_input_matrix.mat: Channel directory for example data (Zenmodo) import. Cell Array
scalp_input_matrix_nk.mat: Channel directory for NK scalp EEG data import. Cell Array
setdiff_bc.m: EEGlab function: 
signalHeader_correctlabels_39.mat: stored data file for NK scalp EEG data import and export
signalHeader_correctlabels_41.mat: stored data file for NK scalp EEG data import and export
signalHeader_correctlabels_43.mat: stored data file for NK scalp EEG data import and export

