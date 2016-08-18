function s=merge_scalar_structs(s1,s2)

s=s1;
field_names=fieldnames(s2);
n_field_names=length(field_names);
for i=1:n_field_names ,
  field_name=field_names{i};
  s.(field_name)=s2.(field_name);
end

end
