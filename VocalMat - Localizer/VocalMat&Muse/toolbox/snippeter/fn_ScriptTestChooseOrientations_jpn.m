function data = fn_ScriptTestChooseOrientations_jpn(data,num_mice,large_val)
%% parameters

% these are the parameters I use for tracking flies
velocity_angle_weight = .03;
max_velocity_angle_weight = .18;
%% do the work
%distributes data tracking structure
for mouse_num = 1:num_mice
    x = data(1,mouse_num).m_afX(1:large_val); %x position
    y = data(1,mouse_num).m_afY(1:large_val); %y position
    theta = -data(1,mouse_num).m_afTheta(1:large_val); %theta;
    
    theta_reconstruct = choose_orientations(x,y,theta,velocity_angle_weight,max_velocity_angle_weight);
    data(1,mouse_num).m_afTheta = -theta_reconstruct;
end
disp(1)
