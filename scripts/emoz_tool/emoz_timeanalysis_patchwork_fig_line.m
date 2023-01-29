function emoz_timeanalysis_patchwork_fig(Spatchw, figopt)
% prop are arranged in a structure with embedded fields :
% prop. CORRECT_OR_NOT(1) . MEDIA_SELECTION(2) . RT_SELECTION(3)
% Fieldnames :
% (1) cor_answer or incor_answer
% (2) all_media ; good_media or bad_media
% (3) all_rt ; before_end_rt or after_end_rt
% exemple prop.cor_answer.all_media.all_rt

if ~isfield(figopt, 'savepath')
    figopt.savepath = pwd;
end
if ~isfield(figopt, 'xlimits')
    figopt.xlimits = [];
end
    
xlimits = figopt.xlimits;
supcond = figopt.supcond;
% supcond = {'neutral', 'incredulity'};
Ns = length(supcond(:,1));

figpath = make_dir(fullfile(figopt.savepath, 'fixprop_fig'), 1);

% Figures of all data types
for i = 1 : Ns
    
    fspk = fieldnames(Spatchw.(supcond{i,1}));
    for j = 1 : length(fspk)
        spk = fspk{j};
        
        Sres = cell(2,1);
        Sres{1} = Spatchw.(supcond{i,1}).(spk);
        Sres{2} = Spatchw.(supcond{i,2}).(spk);

        Sprop = Sres{1}.prop;
        fcor = fieldnames(Sprop);

        for ic = 1 : length(fcor)
            scor = fcor{ic};
            fmed = fieldnames(Sprop.(scor));

            for im = 1 : length(fmed)
                smed = fmed{im};
                frt = fieldnames(Sprop.(scor).(smed));

                for ir = 1 : length(frt)
                    srt = frt{ir};

                    strtyp = [scor,'-', smed, '-', srt];

                    tit = {['[ Emozione ] - Fixation proportions ', strjoin(supcond(i,:),' vs '), ' - ', spk]
                        strtyp};
                        
                    Sres{1}.avg = Sres{1}.prop.(scor).(smed).(srt);
                    Sres{2}.avg = Sres{2}.prop.(scor).(smed).(srt);

                    if plot_prop(Sres, tit, supcond(i,:), xlimits)
                        strtyp(strtyp=='-') = '_';
                        namfig = ['prop_patchw_', spk, '_', strjoin(supcond(i,:),'_'),'_', strtyp];
                        export_fig([figpath, filesep, namfig,'.png'], '-m2', '-zbuffer')
                        close
                    end
                end
            end
        end  
    end
end

function ok = plot_prop(Savg, tit, scond, xlimits)
ok = 1;
avg = {Savg{1}.avg ; Savg{2}.avg};

% Check if enough data to have a relevant plot

if ( sum(isnan(avg{1})==0)/length(avg{1}) < 0.4 ) ||...
        (sum(isnan(avg{2})==0)/length(avg{2}) < 0.4)
    ok = 0;
else

    time = {Savg{1}.time ; Savg{2}.time};
    
    % Color of the 2 avg curves
    col = color_group(2);
    
    % xlimits and ylimits
    if isempty(xlimits)
        xlf = [min(min(time{1}), min(time{2})) max(max(time{1}), max(time{2}))];
        xlf(2) = xlf(2) + 100;
    else
        xlf = xlimits;
    end
    
    ylf = [0 1];
         
    figure
    set(gcf, 'visible', 'off', 'units', 'centimeters', 'position', [5 5 19.2 10])
    set(gca, 'position',  [0.1077 0.1349 0.8511 0.7381])
    hold on
    
    ph = zeros(3,1);
    ph(1) = plot(time{1}, avg{1});
    ph(2) = plot(time{2}, avg{2});
    ph(3) = plot(time{2}, avg{2});
    % set(ph, 'linewidth', 1.2);
    set(ph(1), 'color', col(1,:), 'linewidth', 1.2)
    set(ph(2), 'color', col(2,:), 'linewidth', 0.5)
    set(ph(3), 'color', col(2,:), 'linestyle', '--', 'linewidth', 1.2)

    xlim(xlf)    
    ylim(ylf)

    % Add mean time of interest
    for ir = 1 : 2
        tcrit = Savg{ir}.tcrit_mean(2:4);
        hli = line(repmat(tcrit', 2, 1), repmat(ylf', 1, length(tcrit(:,1))));
        set(hli, 'color', col(ir,:))
        if ir==2
            set(hli, 'linestyle', '--')
        end
        % Add mean reaction time
        tclick = Savg{ir}.tcrit_mean(end);
        
        if isnan(avg{ir}(find(time{ir}>= tclick, 1, 'first')))
            yclick = 0.5;
        else           
            yclick = spline(time{ir}, avg{ir}, tclick);
        end

        hmark = plot(tclick, yclick,'o','markersize',7, 'linewidth', 1);
        set(hmark, 'markerfaceColor', [1.00	0.65 	0.00],...
            'markeredgeColor', col(ir,:)); 
    end

    % Change ytick in "%" 
    ytck = 0 : 0.1 : 1;
    set(gca, 'ytick', ytck', 'yticklabel', num2str(ytck'*100))
    
    % Change xtick with 200 ms-step
    set(gca, 'xtick', 0 : 200 : xlf(end))
    
    set(gca, 'fontsize', 11)
    
    % Add landmark lines 
    line(xlf, [0.50 0.50], 'color', [0.3 0.3 0.3])
    line([0 0], ylf, 'color', [0.3 0.3 0.3])
   
    box on
    grid on
    
    % Add legend
    hleg = [ph(1:2); hmark];
    sleg = [scond , 't_{click}']; 
    lg = legend(hleg, sleg, 'location', 'southeast');
    set(lg, 'fontsize', 11)
                          
    xlabel('Time from t_{ beg} (ms)', 'fontsize', 12)
    ylabel('Mean proportion accross stimuli (%)', 'fontsize', 12)

    annotation('textbox', [0.0809 0.9286 0.8957 0.0661],...
        'string', tit{1}, 'interpreter', 'none', 'fontsize', 13,...
        'fontname', 'AvantGarde', 'linestyle', 'none',...
        'horizontalalignment', 'center', 'fitboxtotext', 'off')
    
    annotation('textbox', [0.0809 0.8677 0.8957 0.0661],...
        'string', tit{2}, 'interpreter', 'none', 'fontsize', 11,...
        'fontangle', 'italic', 'linestyle', 'none',...
        'horizontalalignment', 'center', 'fitboxtotext', 'off')   
    



end

    