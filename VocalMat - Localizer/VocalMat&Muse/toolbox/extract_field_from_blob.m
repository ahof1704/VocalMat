function c=extract_field_from_blob(b,field_name)

n_trials=length(b);
c=cell(n_trials,1);
for i=1:n_trials
  n_vocs_this=length(b{i});
  if n_vocs_this>0
    size_of_one_element_of_b=size(b{i}(1));
    dims_one_element_of_b=length(size_of_one_element_of_b);
    if dims_one_element_of_b==2 && size_of_one_element_of_b(2)==1
      dims_one_element_of_b=1;
      size_of_one_element_of_b(2)=[];
    end
    dims_one_element_of_c=[size_of_one_element_of_b n_vocs_this];
    c{i}=reshape([b{i}.(field_name)],dims_one_element_of_c);
  else
    c{i}=zeros(0,1);
  end
end

end
