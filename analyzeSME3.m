function [ERP, erpcom, SME] = analyzeSME3(ALLERP, erpnames, strnames, txtdir, erpdir)

% set variables
erpcom = '';
ERP    = preloadERP;
numerpnames = length(erpnames);
SME = struct();

erp_eigs = []; % initialize eigenvalue tracker
for e=1:numerpnames

    % load in ERP set
    ERP = pop_loaderp( 'filename', [strnames{e} 'grandaverage.erp'], 'filepath', erpdir );

    % get data quality and other info
    dq = {ERP.dataquality(3).data};
    n_bins = size(dq{1});
    n_bins = n_bins(3);
    cov_avg_dq = cov(mean(dq{1}, 3)); % calculate covariance matrix of averaged dq

    % cov mat summary
    max_cov_mat_eig = max(eig(cov_mat)); % compute eigenvalues
    erp_eigs = [erp_eigs, max_cov_mat_eig]; % update tracker

end

% largets eigenvalue?
noisy_param_idx = find(erp_eigs==max(erp_eigs));

% output 
sprintf("The highest variance is %s", strnmes{noisy_param_idx})

end