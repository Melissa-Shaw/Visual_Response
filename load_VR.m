% Function to load VR mat file from experiment analysis folders.
    % Inputs:
        % shared_drive --> name of shared data drive ('X:' or 'S:')
        % db --> full db struct with experiment details (see makedb_TCB2_MS.m)
        % exp --> experiment number for desired recording
    % Output:
        % VR --> struct with visual responses
function [VR] = load_VR(shared_drive,db,exp) 
    topDir = [shared_drive '\cortical_dynamics\User\ms1121\Analysis Testing\'];
    expDir = [topDir 'Exp_' num2str(exp) '_' db(exp).animal '_' db(exp).date];
    load([expDir '\VR.mat']);
end