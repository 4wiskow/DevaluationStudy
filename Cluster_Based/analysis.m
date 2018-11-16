clear
cfg = [];

[data_hits, data_misses] = Data.getWithinSubjectsDemoStructures();
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg = Design.addWithinSubjectsDesign(cfg, 2);

% [data_hits, data_misses] = Data.getBetweenTrialsDemoStructures();
% cfg.statistic        = 'ft_statfun_indepsamplesT';
% cfg = Design.addBetweenTrialsDesign(cfg, data_hits, data_misses);

cfg.method           = 'montecarlo';
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

% compute clusters
[stat] = ft_freqstatistics(cfg, data_hits, data_misses)

% draw plots
cfg = [];
cfg.alpha  = 0.025;
cfg.parameter = 'stat';
cfg.zlim   = [-4 4];
cfg.layout = 'biosemi128';
ft_clusterplot(cfg, stat);