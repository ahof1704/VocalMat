function im=rgbImageFromPointerCData(cdata,backgroundColor)

nPad=2;  % number of pixels to pad on all sides
[nRows,nCols]=size(cdata);
%im=zeros(nRows+2*nPad,nCols+2*nPad,3);
black=reshape([0 0 0],[1 1 3]);
white=reshape([1 1 1],[1 1 3]);
backgroundColor=reshape(backgroundColor,[1 1 3]);
im=repmat(backgroundColor,[nRows+2*nPad nCols+2*nPad 1]);
for j=1:nCols
  for i=1:nRows
    cdataThis=cdata(i,j);
    if cdataThis==1
      im(i+nPad,j+nPad,:)=black;
    elseif cdataThis==2
      im(i+nPad,j+nPad,:)=white;
    end
  end
end

end