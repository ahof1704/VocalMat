function [ date_str,let_str,base_dir_name] = fn_create_experimental_list( varargin )
%fn_create_experimental_list 
%   creates cell arrays of experimental date_strings, experiment letter
%   names, and base name directory
%
%Input:
%   none
%
%Output:
%   date_str = cell with size = 1xn; all dates experiments were run;
%       strings
%   let_str = cell with size = 1xn; letter in name of each experiment to be 
%       analysed; strings
%   base_dir_name = cell with size = 1xn; name of base directory with data; 
%       strings 


%parse input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(0,0,nargs,'struct'));

%data to process
date_str=cell(0,1);
%single mouse
date_str{end+1}='06052012';
date_str{end+1}='06062012';
date_str{end+1}='06102012';
date_str{end+1}='06112012';
date_str{end+1}='06122012';
date_str{end+1}='06122012';
date_str{end+1}='06132012';  % this is the one with the least vocs for single mouse data
date_str{end+1}='06132012';
%multiple mouse
date_str{end+1}='08212012';
date_str{end+1}='08232012';
date_str{end+1}='09042012';
date_str{end+1}='09122012';
date_str{end+1}='10052012';
date_str{end+1}='10062012';
date_str{end+1}='10072012';
date_str{end+1}='10082012';
date_str{end+1}='11102012';
date_str{end+1}='11122012';
date_str{end+1}='12312012';
date_str{end+1}='01012013';
date_str{end+1}='01022013';
date_str{end+1}='03032013';

let_str=cell(0,1);
%single mouse
let_str{end+1}='D';
let_str{end+1}='E';
let_str{end+1}='E';
let_str{end+1}='D';
let_str{end+1}='D';
let_str{end+1}='E';
let_str{end+1}='D';
let_str{end+1}='E';
%multiple mouse
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';

base_dir_name=cell(0,1);
%single mouse data
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_sys_test';
%multiple mouse data
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';
base_dir_name{end+1} = 'A:\Neunuebel\ssl_vocal_structure\';

end

