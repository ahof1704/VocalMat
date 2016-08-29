function [ha,va]=f(theta)
  
zone=mod(round(theta*4/pi),8);
switch zone
  case  0
    va='middle';
    ha='left';
  case +1
    va='bottom';
    ha='left';
  case +2
    va='bottom';
    ha='center';
  case +3
    va='bottom';
    ha='right';
  case +4
    va='middle';
    ha='right';
  case +5
    va='top';
    ha='right';
  case +6
    va='top';
    ha='center';
  case +7
    va='top';
    ha='left';
end      

