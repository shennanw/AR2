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

