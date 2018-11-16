[data_hits, data_misses] = Data.getBetweenSamplesDemoStructures();
% [hits, misses] = Data.getBetweenTrialsDemoStructures();

cfg = [];
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.5;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 500;
% specifies with which sensors other sensors can form clusters
cfg_neighb.method    = 'distance';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, data_hits);
cfg.keeptrials = 'yes';

% between subjects paradigm
subj = 2;
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

% % between trials paradigm
% nHits = size(data_hits.powspctrm, 1);
% nMisses = size(data_misses.powspctrm, 1);
% design = zeros(1, nHits + nMisses);
% design(1, 1:nHits) = 1;
% design(1, nHits+1:nHits+nMisses) = 2;
% 
% cfg.design = design';
% cfg.ivar = 1;
% 
% data_hits.cfg = cfg;
% data_misses.cfg = cfg;

% compute clusters
[stat] = ft_freqstatistics(cfg, data_hits, data_misses)

% draw plots
cfg = [];
cfg.alpha  = 0.025;
cfg.parameter = 'stat';
cfg.zlim   = [-4 4];
cfg.layout = 'biosemi128';
ft_clusterplot(cfg, stat);