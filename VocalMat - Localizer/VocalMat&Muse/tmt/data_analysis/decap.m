function [v_cos,artifact]=f(t,v,command,post_step_blank_time)

[v_cos,v_bal,artifact]=...
  debridge(t,v,command,post_step_blank_time,0);
