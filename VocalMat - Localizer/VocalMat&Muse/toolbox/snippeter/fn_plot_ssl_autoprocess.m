function fn_plot_ssl_autoprocess( saving_dir, mouse, fmt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
count = 0;
for z = 1:size(mouse,2)
    
    count = count + 1;
    %     syl_name = mouse(z).syl_name(1:end-4);
    syl_name = mouse(z).syl_name;
    %spectrograms
    cd (sprintf('%s\\specgram',saving_dir))
    filename1 = sprintf('Spectrogram_%s_ch1',syl_name);
    a = imread(filename1, fmt);
    filename2 = sprintf('Spectrogram_%s_ch2',syl_name);
    b = imread(filename2, fmt);
    filename3 = sprintf('Spectrogram_%s_ch3',syl_name);
    c = imread(filename3, fmt);
    filename4 = sprintf('Spectrogram_%s_ch4',syl_name);
    d = imread(filename4, fmt);
    %voltage
    cd (sprintf('%s\\voltage',saving_dir))
    filename5 = sprintf('Voltage_%s_ch1',syl_name);
    e = imread(filename5, fmt);
    filename6 = sprintf('Voltage_%s_ch2',syl_name);
    f = imread(filename6, fmt);
    filename7 = sprintf('Voltage_%s_ch3',syl_name);
    g = imread(filename7, fmt);
    filename8 = sprintf('Voltage_%s_ch4',syl_name);
    h = imread(filename8, fmt);
    
    %xcorr
    cd (sprintf('%s\\xcorr',saving_dir))
    filename9 = sprintf('Xcorr_%s_ch12',syl_name);
    i = imread(filename9, fmt);
    filename10 = sprintf('Xcorr_%s_ch13',syl_name);
    j = imread(filename10, fmt);
    filename11 = sprintf('Xcorr_%s_ch14',syl_name);
    k = imread(filename11, fmt);
    filename12 = sprintf('Xcorr_%s_ch23',syl_name);
    l = imread(filename12, fmt);
    filename13 = sprintf('Xcorr_%s_ch24',syl_name);
    m = imread(filename13, fmt);
    filename14 = sprintf('Xcorr_%s_ch34',syl_name);
    n = imread(filename14, fmt);
    
    %mice positions
    cd (sprintf('%s\\mouse_position_images',saving_dir))
    filename15 = sprintf('Image_mice_%s',syl_name);
    o = imread(filename15, fmt);
    
    %     if strcmp(mouse(1,z).tag,'GOOD')==1
    %         %colormap
    %         cd (sprintf('%s\\colormaps',saving_dir))
    %         filename16 = sprintf('Colormap_%s',syl_name);
    %         p = imread(filename16, fmt);
    %         %probability_plots
    %         cd (sprintf('%s\\probability_plots',saving_dir))
    %         filename17 = sprintf('Prob_abs_diff_%s_mouse1',syl_name);
    %         q = imread(filename17, fmt);
    %         filename18 = sprintf('Prob_abs_diff_%s_mouse2',syl_name);
    %         r = imread(filename18, fmt);
    %         %quadlateration
    %         cd (sprintf('%s\\quadlateration',saving_dir))
    %         filename19 = sprintf('Quadlateration_%s',syl_name);
    %         s = imread(filename19, fmt);
    % %         filename20 = sprintf('Distance_distribution_%s_mouse2',syl_name);
    % %         t = imread(filename20, fmt);
    %         clear filename
    %     end
    
    %     quadlateration
    cd (sprintf('%s\\quadlateration',saving_dir))
    filename19 = sprintf('Quadlateration_%s',syl_name);
    s = imread(filename19, fmt);
    
    scrsz = get(0,'ScreenSize');
    handle1 = figure('Position', [scrsz(1)*100 scrsz(2)*100 (scrsz(3)-(scrsz(3)/10)) (scrsz(4)-(scrsz(4)/5))]);
    
    rows = 8;
    cols = 4;
    
    %     subplot(cols,rows,1)
    %     imagesc(a);
    %     subplot(cols,rows,2)
    %     imagesc(b);
    %     subplot(cols,rows,3)
    %     imagesc(c);
    %     subplot(cols,rows,4)
    %     imagesc(d);
    %     subplot(cols,rows,5)
    %     imagesc(e);
    %     subplot(cols,rows,6)
    %     imagesc(f);
    %     subplot(cols,rows,7)
    %     imagesc(g);
    %     subplot(cols,rows,8)
    %     imagesc(h);
    %     subplot(cols,rows,9)
    %     imagesc(i);
    %     subplot(cols,rows,10)
    %     imagesc(j);
    %     subplot(cols,rows,13)
    %     imagesc(k);
    %     subplot(cols,rows,14)
    %     imagesc(l);
    %     subplot(cols,rows,17)
    %     imagesc(m);
    %     subplot(cols,rows,18)
    %     imagesc(n);
    % %     subplot(cols,rows,11)
    % %     imagesc(o);
    %     subplot(cols,rows,[11 12 15 16 19 20])
    %     imagesc(s);
    
    subplot(rows,cols,1)
    imagesc(a);
    subplot(rows,cols,2)
    imagesc(b);
    subplot(rows,cols,3)
    imagesc(c);
    subplot(rows,cols,4)
    imagesc(d);
    subplot(rows,cols,5)
    imagesc(i);
    subplot(rows,cols,6)
    imagesc(j);
    subplot(rows,cols,9)
    imagesc(k);
    subplot(rows,cols,10)
    imagesc(l);
    subplot(rows,cols,13)
    imagesc(m);
    subplot(rows,cols,14)
    imagesc(n);
    subplot(rows,cols,[7 8 11 12 15 16])
    imagesc(o);
    subplot(rows,cols,17:32)
    imagesc(s);
    
    subplotnumber = 32;
    
    %     if strcmp(mouse(1,z).tag,'GOOD')==1
    %         subplot(5,4,16)
    %         imagesc(p);
    %         subplot(5,4,17)
    %         imagesc(q);
    %         subplot(5,4,18)
    %         imagesc(r);
    %         subplot(5,4,19)
    %         imagesc(s);
    % %         subplot(5,4,20)
    % %         imagesc(t);
    %         subplotnumber = 19;
    %     end
    
    for i = 1:subplotnumber
        if i ~= [7 8 11 12 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32]
            subplot(rows,cols,i)
            axis off
            OP = get(gca,'OuterPosition');
            OP(1) = OP(1)-2*(0.0062);
            OP(2) = OP(2)-2*(0.0124);
            OP(3) = OP(3)+2*(0.0124);
            OP(4) = OP(4)+2*(0.0247);
            set(gca,'OuterPosition',OP)
        elseif i == 7
            subplot(rows,cols,[7 8 11 12 15 16])
            axis off
            OP = get(gca,'OuterPosition');
            OP(1) = OP(1)-2*(0.0062);
            OP(2) = OP(2)-2*(0.0124);
            OP(3) = OP(3)+4*(0.0124);
            OP(4) = OP(4)+4*(0.0247);
        elseif i == 17
            subplot(rows,cols,17:32)
            axis off
            OP = get(gca,'OuterPosition');
            OP(1) = OP(1)-2*(0.0062);
            OP(2) = OP(2)-2*(0.0124);
            OP(3) = OP(3)+4*(0.0124);
            OP(4) = OP(4)+4*(0.0247);
        end
    end
    
    if (count<10)
        page_number = sprintf('Page 000%g',count);
    elseif (count>=10) && (count<100)
        page_number = sprintf('Page 00%g',count);
    elseif (count>=100) && (count<1000)
        page_number = sprintf('Page 0%g',count);
    elseif (count>=1000)
        page_number = sprintf('Page %g',count);
    end
    
    cd (saving_dir)
    if isdir('autoprocess')==0
        mkdir('autoprocess')
        cd 'autoprocess'
    else
        cd 'autoprocess'
    end
    saveas(gcf,page_number,'pdf')
    close (handle1)
    clear subplotnumber
end
end

