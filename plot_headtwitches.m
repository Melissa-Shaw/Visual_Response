function plot_headtwitches(db,con_exp,tcb_exp)

    con_HTR = ones(numel(con_exp),2); 
    tcb_HTR = ones(numel(tcb_exp),2)+1;
    
    for i = 1:numel(con_exp)
        if isempty(db(con_exp(i)).HTR)
            con_HTR(i,2) = NaN;
        else
            con_HTR(i,2) = sum(db(con_exp(i)).HTR)/9;
        end
    end
    for i = 1:numel(tcb_exp)
        if isempty(db(tcb_exp(i)).HTR)
            tcb_HTR(i,2) = NaN;
        else
            tcb_HTR(i,2) = sum(db(tcb_exp(i)).HTR)/9;
        end
    end
    
    swarmchart(con_HTR(:,1),con_HTR(:,2),'ko');
    hold on; swarmchart(tcb_HTR(:,1),tcb_HTR(:,2),'ro');
    xlim([0.5 2.5]);
    xticks([1 2]); xticklabels({'Control', 'TCB-2'});
    ylabel('HTR (twitch/min)'); axis square; box off;

    
end