clear;

layoutName = 'biosemi128.lay';

[hits, misses] = Data.getMegaData();
Y = cat(1, ...
        ones(size(hits, 3), 1), ...
        ones(size(misses, 3), 1) + 1 ...
        );
X = permute(cat(3, hits, misses), [3 2 1]);
X = zscore(X);
X = cat(3, mean(X(:, :, 1:256), 3),...
           mean(X(:, :, 256:512), 3),...
           mean(X(:, :, 512:768), 3),...
           mean(X(:, :, 768:1024), 3));

cfg = [];
cfg.layout = layoutName;
layout = ft_prepare_layout(cfg);

cfg.method = 'distance';
cfg.neighbourdist   = .1;
cfg.nb = ft_prepare_neighbours(cfg);
% ft_neighbourplot(cfg);

param = mv_get_classifier_param('svm');
param.classifier = 'svm';
param.kernel = 'linear';
param.balance = 'oversample';
param.repeat = 1;
param.outline = layout.outline;
param.average = 0; % dont average time points

[perf, result] = mv_searchlight(param, X, Y);

channelPos = layout.pos(1:128, :); % remove CMNT and SCALE
h = mv_plot_topography(param, perf, channelPos);