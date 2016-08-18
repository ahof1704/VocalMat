function temps = fn_load_temps(temp_list,load_saved_temps,number_sessions)
%creats a matrix with the temps at time of recording
if strcmp(load_saved_temps,'y')==1
    load(temp_list)
else
    for i = 1:number_sessions
        temps(i,1) = input('What was the tempurater (C) at time of recording?');
    end
    save('temps','temps')
end

