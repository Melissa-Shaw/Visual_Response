function plotDriftmap_NP24(shared_drive,db,exp)

% addpaths
addpath(genpath([shared_drive '\cortical_dynamics\Shared\Code\github_cortex-lab_spikes']));
addpath([shared_drive '\cortical_dynamics\Shared\Code\github_kwikteam_npy-matlab']);

% find spikeTimes,spikeAmps, and spikeDepths from kilosort outputs
ksDir = db(exp).dir;
[spikeTimes, spikeAmps, spikeDepths] = ksDriftmap(ksDir);

% create array for NP24 horz row arrangement
shank_blocks = [1 48; 97 144; 49 96; 145 192; 193 240; 289 336; 241 288; 337 384];
bps = 2; % number of blocks per shank

% divide depths by 10 to more intuitive with channels
spikePos = spikeDepths./10;

% plot signal
for block = 1:size(shank_blocks,1)
    block_pos = spikePos>=shank_blocks(block,1) & spikePos<shank_blocks(block,2); % spikePos in singular shank block
    if block == 1
        plotDriftmap(spikeTimes(block_pos), spikeAmps(block_pos), spikePos(block_pos));
        top_chan = shank_blocks(block,2);
    else
        gap = shank_blocks(block,1)-top_chan; % find the difference in channels between end of first block and start of second
        plotDriftmap(spikeTimes(block_pos), spikeAmps(block_pos), spikePos(block_pos)-gap); % start y axis position from next whole number (e.g. 49)
        top_chan = shank_blocks(block,2)-gap;
    end
    hold on
    if mod(block,bps) == 0
        yline(top_chan,'r');
    end
end


end