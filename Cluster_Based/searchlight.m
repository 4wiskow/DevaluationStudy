clear;

layoutName = 'biosemi128.lay';

[hits, misses] = Data.getMegaData(1);
Y = cat(1, ...
        ones(size(hits, 3), 1), ...
        ones(size(misses, 3), 1) + 1 ...
        );
X = permute(cat(3, hits, misses), [3 2 1]);
X = zscore(X);
X = cat(3, mean(X(:, :, 1:128), 3),...
           mean(X(:, :, 128:256), 3),...
           mean(X(:, :, 256:384), 3),...
           mean(X(:, :, 348:512), 3));

cfg = [];
cfg.layout = layoutName;
layout = ft_prepare_layout(cfg);
channelPos = layout.pos(1:128, :); % remove CMNT and SCALE

param = mv_get_classifier_param('svm');
param.classifier = 'svm';
param.kernel = 'linear';
param.balance = 'oversample';
param.repeat = 1;
param.outline = layout.outline;
param.average = 0; % dont average time points
param.nb = squareform(pdist(channelPos));
param.size = 0;

[perf, result] = mv_searchlight(param, X, Y);

h = mv_plot_topography(param, perf, channelPos);