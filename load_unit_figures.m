function load_unit_figures(db,exp)

[VR] = load_VR('X:',db,exp);
pre_sig_units = VR.grat.sig_response{1}(:,1) & VR.grat.sig_response{1}(:,2) & VR.grat.sig_response{1}(:,3); 
post_sig_units = VR.grat.sig_response{2}(:,1) & VR.grat.sig_response{2}(:,2) & VR.grat.sig_response{2}(:,3); 
sig_clu = VR.clusteridx(pre_sig_units | post_sig_units);

for clu = 1:numel(sig_clu)
    uiopen(['X:\cortical_dynamics\User\ms1121\Analysis Testing\Visual_Response_Figures\Exp_Summaries\Exp_' num2str(exp) '_Unit_Figures\Unit_' num2str(sig_clu(clu)) '.fig'],1)
end

end