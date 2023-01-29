% Write all the data in a big table for a part of the data
tabfile = 'emoz_fixations_per_crop_incrneut_F_correct.txt';

femo = fieldnames(Sta);
Ne = length(femo);

Stab = [];
for i = 1 : Ne
    
    emo = femo{i};
    
    fspk = fieldnames(Sdat.(femo{i}));
    Ns = length(fspk);
    
    for j = 1 : Ns
        spk = fspk{j};

        Scond = Sta.(emo).(spk);  
            
        if i==1 && j==1
            subj = Scond.subj;
            Nsubj = length(subj);
        end
        
        mednames = Scond.medianames;  
        Nmed = length(mednames); 
        
        corc = Scond.corclick;
        
        % All data locked on t_beg
        Sdata = Scond.datalign.tbeg;
        
        time = Sdata.time_tab;
        fix = Sdata.fix_taball;
        
        tcr = Sdata.tcrit;
        tper = [tcr.tbeg tcr.tnoun tcr.tverb tcr.tend];
        Nperf = length(tper(1,:)); 
        
        Nper = Nperf - 1;
        
        tclick = Sdata.tclick;
        tclick_tbeg = tclick; % Already in relation to tbeg
        tclick_tend = tclick - repmat(tcr.tend, 1, Nsubj);
        
        tperms = [repmat(tper', [ 1 1 Nsubj]) ; reshape(tclick, [1 size(tclick)])];
        
        rednam = cell(Nmed, 1);
        fixms = cell(Nmed, Nsubj);
        perms = cell(Nmed, Nsubj);
        for im = 1 : Nmed
            
            % Reduced medianame
            mednam = mednames{im};
            numeds = mednam(isstrprop(mednam, 'digit'));
            if length(numeds) == 1
                numeds = ['0', numeds]; %#ok
            end
            rednam{im} = ['S',numeds, upper(mednam(1))] ;
            
            % Add period indication in the big tab
            for is = 1 : Nsubj
                tpp = tperms(:, im, is);
                subjfix = squeeze(fix(im, is, :));
                ibeg = find(time >= 0, 1, 'first');
                iend = find(isnan(subjfix)==0, 1, 'last');
                
                
                croptime = time(ibeg : iend);
                Nt = length(croptime);
                indper = zeros(1, Nt);                
                
                % Special case for the last period when no click 
                % (tend <-> last isnan(fixall)==0)
                if tpp(end)==0
                    tpp(end) = 1e4;
                end
                for it = 1 : Nt
                    tpoint = croptime(it);
                    iper = find(tpp > tpoint, 1, 'first');
                    if isempty(iper) 
                        ibound = find(tpp==tpoint);
                        if ~isempty(ibound)
                            indper(it) = find(tpp==tpoint)-1;
                        end
                    else
                        indper(it) = iper-1;
                    end
                end
                fixms{im, is} = subjfix(ibeg:iend);   
                perms{im, is} = indper;
            end   
        end
        Stab.(emo).(spk).medianames = Scond.medianames;
        Stab.(emo).(spk).mednames_red = rednam;
        Stab.(emo).(spk).subj = Scond.subj;
        
        Stab.(emo).(spk).correct = Scond.corclick;
        
        Stab.(emo).(spk).norming = Scond.norming;
        Stab.(emo).(spk).freq = Scond.freq;
        
        Stab.(emo).(spk).tclick_tbeg = tclick_tbeg;
        Stab.(emo).(spk).tclick_tend = tclick_tend;
        
        Stab.(emo).(spk).fix = fixms;
        Stab.(emo).(spk).per = perms;
    end
end

% Write it
fid = fopen(tabfile,'w');
hdr = ['Condition\t',...
    'Speaker\t',... 
    'Participant\t',... 
    'Media\t',... 
    'MediaCrop\t',...   
    'Period\t',... 
    'Nfix_fail\t',...
    'Nfix_succ\t',...
    'Correct\t',...    
    'tclick_tbeg\t',... 
    'tclick_tend\t',...    
    'Norming\t',... 
    'f0T1\t',... 
    'f0T2\t',... 
    'f0slope\t',... 
    'f0time\n']; 
% 'Cond'  'Spk'  'Part' 'Media'  'MedCrp\t'  'Per' 'Fix_0'  Fix_ones 
%  %s     %s     %s     %s      %s            %d    %d       %d
% 'Cor'    'tc_tbeg' 'tc_tend'  'Norm' 'f0T1'  'f0T2' 'f0slope' 'f0time'
% %d       %4.1f       %4.1f      %1.2f   %4.1f %4.1f   %1.2f    %3.3f\n

colform = '%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%4.1f\t%4.1f\t%1.2f\t%4.1f\t%4.1f\t%1.2f\t%3.3f\n';

fprintf(fid, hdr);

for i = 4:5 %1 : Ne

    fspk = fieldnames(Stab.(femo{i}));

    for j = 2:2 %1 : length(fspk)
        spk = fspk{j};
        emo = femo{i};
        Scond = Stab.(emo).(spk);
        if strcmpi(spk(1), 'w')==1
            uspk = 'F';
        else
            uspk = 'M';
        end
        subj = Scond.subj;
        Nsubj = length(subj);
        Nmed = length(Scond.medianames);

        for is = 1 : Nsubj     
            for im = 1 : Nmed
             
                vper = Scond.per{im, is};
                uper = unique(vper);
                Nup = length(uper);
                if Scond.correct(im, is)==1
                for ip = 1 : Nup
                    nb_zer = sum(Scond.fix{im, is}(vper==uper(ip))==0);
                    nb_one = sum(Scond.fix{im, is}(vper==uper(ip))==1);
                    
                    fprintf(fid, colform, emo, uspk, subj{is}, ...
                                Scond.medianames{im}, Scond.mednames_red{im},...
                                uper(ip),  nb_zer, nb_one,...
                                Scond.correct(im, is), Scond.tclick_tbeg(im, is),...
                                Scond.tclick_tend(im, is), Scond.norming(im),...
                                Scond.freq.t1(im), Scond.freq.t2(im), Scond.freq.slope(im),...
                                Scond.freq.time(im));
                end
                end
            end
        end
    end
end

fclose(fid);
    