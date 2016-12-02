
lista = rdir([pwd, '\**\*.png']);

for i=1:size(lista,1)
	copyfile(lista(i).name,'G:\Ultrasound vocalizations\2016_08_15_Agrp-Trpv1(P10)-35C\ch1\1795_Agrp-Trpv1_2nd_Stage\All')
end

