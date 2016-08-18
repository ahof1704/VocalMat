function [phat,pci] = tlsfit(x,alpha,cens,freq,opts)

if nargin < 2 || isempty(alpha), alpha = .05; end
if nargin < 3 || isempty(cens), cens = zeros(size(x)); end
if nargin < 4 || isempty(freq), freq = ones(size(x)); end
if nargin < 5, opts = []; end

% Robust estimators for the mean and std dev of a normal, and method
% of moments on t-kurtosis for nu
xunc = x(cens == 0);
k = max(kurtosis(xunc), 4);
start = [median(xunc), 1.253.*mad(xunc), 2.*(2.*k-3)./(k-3)];

% The default options include turning fminsearch's display off.  This
% function gives its own warning/error messages, and the caller can turn
% display on to get the text output from fminsearch if desired.
options = statset(statset('tlsfit'), opts);
tolBnd = options.TolBnd;
options = optimset(options);

% Maximize the log-likelihood with respect to mu, sigma, and nu.
[phat,nll,err,output] = ...
    fminsearch(@tls_nloglf, start, options, x, cens, freq, tolBnd);
if (err == 0)
    % fminsearch may print its own output text; in any case give something
    % more statistical here, controllable via warning IDs.
    if output.funcCount >= options.MaxFunEvals
        wmsg = 'Maximum likelihood estimation did not converge.  Function evaluation limit exceeded.';
    else
        wmsg = 'Maximum likelihood estimation did not converge.  Iteration limit exceeded.';
    end
    if phat(3) > 100 % degrees of freedom became very large
       wmsg = sprintf('%s\n%s', wmsg, ...
                      'The normal distribution might provide a better fit.');
    end
    warning('stats:tlsfit:IterOrEvalLimit',wmsg);
elseif (err < 0)
    error('stats:tlsfit:NoSolution',...
          'Unable to reach a maximum likelihood solution.');
end

if nargout > 1
    acov = mlecov(phat, x, 'nloglf',@tls_nloglf, 'cens',cens, 'freq',freq);
    probs = [alpha/2; 1-alpha/2];
    se = sqrt(diag(acov))';

    % Compute the CI for mu using a normal approximation for muhat.
    pci(:,1) = norminv(probs, phat(1), se(1));

    % Compute the CI for sigma using a normal approximation for
    % log(sigmahat), and transform back to the original scale.
    % se(log(sigmahat)) is se(sigmahat) / sigmahat.
    logsigci = norminv(probs, log(phat(2)), se(2)./phat(2));
    pci(:,2) = exp(logsigci);

    % Compute the CI for nu using a normal distribution for nuhat.
    pci(:,3) = norminv(probs, phat(3), se(3));
end
