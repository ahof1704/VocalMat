load('A:\Neunuebel\ssl_vocal_structure\10072012\Data_analysis10\Test_B_1_Mouse.mat')

path_d = 'A:\Neunuebel\ssl_vocal_structure\10072012\';
dir3 = [path_d 'Results\Tracks'];
video_fname_prefix = 'Test_B_1';
num_mice = 4;
cd (dir3)
load (video_fname_prefix)

mouse = fn_incorporate_tracker_data_different_rf_frames(astrctTrackers,mouse,num_mice);