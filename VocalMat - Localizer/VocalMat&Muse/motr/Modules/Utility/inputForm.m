function str=inputForm(x)

% A Matlab analog to Mathematica's InputForm[].

switch(class(x))
    case 'logical'
        str=inputForm_logical(x);
    case 'double'
        str=inputForm_double(x);
    case 'char'
        str=inputForm_char(x);
    case 'struct'
        str=inputForm_struct(x);
    case 'cell'
        str=inputForm_cell(x);
end

end




function str=inputForm_logical(x)

if ndims(x)>2
    error('No simple input form for ndims(x)>2.');
end

[m,n]=size(x);

if m==0||n==0
    str=sprintf('false(%d,%d)',m,n);
    return;
end

if m>1 || n>1
    str='[';
else
    str='';
end
for i=1:m
    for j=1:n
        if x(i,j)
            str_el='true';
        else
            str_el='false';
        end
        str=[str str_el];
        if j<n
            str=[str ' '];
        end
    end
    if i<m
        str=[str ';'];
    end
end
if m>1 || n>1
    str=[str ']'];
end

end





function str=inputForm_double(x)

if ndims(x)>2
    error('No simple input form for ndims(x)>2.');
end

[m,n]=size(x);

if m==0||n==0
    str=sprintf('zeros(%d,%d)',m,n);
    return;
end

if m>1 || n>1
    str='[';
else
    str='';
end
for i=1:m
    for j=1:n
        str=[str sprintf('%0.15g',x(i,j))];
        if j<n
            str=[str ' '];
        end
    end
    if i<m
        str=[str ';'];
    end
end
if m>1 || n>1
    str=[str ']'];
end

end





function str=inputForm_char(x)

if ndims(x)>2
    error('No simple input form for ndims(x)>2.');
end

[m,n]=size(x);

if m==0 && n==0
    str='''''';  % if you type "''", that yields a 0 x 0 char array
    return;
end
if m==0 || n==0
    str=sprintf('char(zeros(%d,%d))',m,n);
    return;
end

if m>1
  str='[';
else
  str='';
end
for i=1:m
    str=[str '''' x(i,:) ''''];
    if i<m
        str=[str ';'];
    end
end
if m>1
    str=[str ']'];
end

end





function str=inputForm_struct(x)

if ndims(x)>2
    error('No simple input form for ndims(x)>2.');
end

[m,n]=size(x);

fn=fieldnames(x);
n_fn=length(fn);
str='struct(';
for k=1:n_fn
    fn_this=fn{k};
    str_this=inputForm_struct_field(x,fn_this);
    str=[str '''' fn_this ''',' str_this]; 
    if k<n_fn
        str=[str ','];
    end
end
str=[str ')'];

end






function str=inputForm_struct_field(s,fn)
% s a structure array, fn a field name
% outputs a string representing a cell array corresponding to
% a single field of s.
% this isn't really a proper input form by itself, but
% we need to generate is to create the output form for non-scalar
% structure arrays

[m,n]=size(s);

if m==0||n==0
    str=sprintf('cell(%d,%d)',m,n);
    return;
end

str='{';
for i=1:m
    for j=1:n
        val=getfield(s,{i,j},fn);
        val_str=inputForm(val);
        str=[str val_str];
        if j<n
            str=[str ' '];
        end
    end
    if i<m
        str=[str ';'];
    end
end
str=[str '}'];

end





function str=inputForm_cell(x)

if ndims(x)>2
    error('No simple input form for ndims(x)>2.');
end

[m,n]=size(x);

if m==0||n==0
    str=sprintf('cell(%d,%d)',m,n);
    return;
end

str='{';
for i=1:m
    for j=1:n
        val=x{i,j};
        val_str=inputForm(val);
        str=[str val_str];
        if j<n
            str=[str ' '];
        end
    end
    if i<m
        str=[str ';'];
    end
end
str=[str '}'];

end
