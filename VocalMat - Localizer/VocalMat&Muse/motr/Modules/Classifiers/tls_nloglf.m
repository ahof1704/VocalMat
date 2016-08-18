
function nll = tls_nloglf(parms, x, cens, freq, tolBnd)
%TLS_NLOGLF Objective function for t location-scale maximum likelihood.
mu = parms(1);
sigma = parms(2);
nu = parms(3);

% Restrict sigma and nu to the open interval (0, Inf).
if nargin > 4
    if sigma < tolBnd || nu < tolBnd
        nll = Inf;
        return
    end
end

t = (x - mu) ./ sigma;
w = nu + (t.^2);
logw = log(w);

L = -.5.*(nu+1).*logw + gammaln(.5.*(nu+1)) - gammaln(.5.*nu) + 0.5.*nu.*log(nu) - log(sigma) - .5.*log(pi);
ncen = sum(freq.*cens);
if ncen > 0
    cen = (cens == 1);
    if nu < 1e7  % Use the standard formula
        Scen = betainc(nu ./ w(cen), .5.*nu, 0.5) ./ 2;

        % Reflect for negative t.
        reflect = (t(cen) < 0);
        Scen(reflect) = 1 - Scen(reflect);

    else  % Use a normal approximation.
        Scen = log(0.5 * erfc(t(cen) ./ sqrt(2)));
    end
    L(cen) = log(Scen);
end
nll = -sum(freq .* L);

% Don't yet have dbetainc, so can't compute an analytic gradient with censoring.
%
% if nargout > 1
%     dL1 = (nu+1).*t./(w.*sigma);
%     dL2 = t.*dL1 - 1./sigma;
%     dL3 = .5.*(-logw - (nu+1)./w + psi(.5.*(nu+1)) - psi(.5.*nu) + log(nu) + 1);
%     if ncen > 0
% %         dL1(cen) = ;
% %         dL2(cen) = ;
% %         dL3(cen) = ;
%     end
%     ngrad = -[sum(freq .* dL1) sum(freq .* dL2) sum(freq .* dL3)];
% end