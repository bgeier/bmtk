% GEX2FOB Convert gene expression data to fold-over baseline
%   GEX2FOB( '-res', GEXFILE, '-invset', INVARIANTSETFILE, '-ybio', YBIOFILE)
%   INPUTS:
% -res      : gene expression file (.gct format)
% -invset   : list of invariant set of genes (.gmx format)
% -yref     : reference FOB file (.gct format)
% -out      : parent outpath, char (default: pwd)
% -rpt      : output prefix path, char (default: myanalysis)
% -log2     : logical indicator, true (apply log2 )
% -debug    : turn debuggin on, save intermediate files, logical (default: false)
%   
function gex2fob( varargin )
toolName = mfilename;
% parse args
pnames = {'-res', '-invset', '-yref', '-out', '-debug', '-rpt','-log2', '-fitmodel','-precision','-minval','-maxval'};
dflts =  {    '',     '',     '',      '.',      false,    toolName, true, 'power', 4, 0, 15 };
arg = getargs2(pnames, dflts,varargin{:});            
print_tool_params2(toolName, 1, arg);

% invariant set
if ~isfileexist(arg.invset)
    error (toolName, '%s not found', arg.invset);
end

% reference calib values
if isfileexist(arg.yref)
    [yref.ge, yref.gn, yref.gd, yref.sid] = parse_gct(arg.yref, 'class', 'double');
else
    error (toolName, '%s not found', arg.yref);
end

% gex file
if isfileexist(arg.res)
    [sc.ge, sc.gn, sc.gd, sc.sid] = parse_gct(arg.res);
    if arg.log2
        fprintf ('Log2 transforming\n');
        sc.ge = safe_log2(sc.ge);
    end
else
    error (toolName, '%s not found', arg.res);
end

% get calib matrix
[calib.ge, calib.gn, calib.gd, calib.sid] = gen_calib_matrix(arg.invset, sc);

%% Perform normalization

wkdir = mkworkfolder(arg.out, arg.rpt);
fid = fopen(fullfile(wkdir, sprintf('%s_params.txt', arg.rpt)), 'wt');
print_tool_params2(arg.rpt, fid, arg);
fclose (fid);
fprintf ('Starting normalization...\n');
normalize_core(sc, calib, yref.ge, arg, wkdir);


%% CORE routine
function normalize_core(sc, calib, ybio_ref, arg, wkdir)

[numFeatures, numSamples ] = size(sc.ge);
numLevels = size(calib.ge,1);
totLevels = numLevels+3;

% y-observed values for each level
yobsmat = zeros(numSamples, totLevels, 'single');

% calib curve used for fitting
cal_obs = zeros(numSamples, totLevels-2, 'single');
% calib curve after fit
cal_fit = zeros(numSamples, totLevels-2, 'single');

% store intermediate yobs
if arg.debug
    yobsmat_med = deal(yobsmat);
end

% normalized values for gexFile
fob.ge = zeros(numFeatures, numSamples, 'single');
fob.gn = sc.gn;
fob.gd = sc.gd;
fob.sid = sc.sid;

% sample desc
desc=sc.sid;
qcpass=0;
qcpass_idx = false(numSamples,1);
% samplewise report of fits
qcrpt = struct('sample', fob.sid ,'qcpass', qcpass_idx, 'fittype', arg.fitmodel);
tic
for ii = 1:numSamples
    yobs = zeros(totLevels,1);
    
    %find black pt
    yobs(1) = prctile (sc.ge(:,ii), 1);
    
    % non zero black pt needed for power fit
    yobs(1) = max(yobs(1),1);    
    
    % extract invariant sets
    yobs(2:numLevels+1) = calib.ge(:, ii);

    if arg.debug
        %store median yobs
        yobsmat_med(ii,:) = yobs;
    end
   
    % lowess smoothing of yobs
    yobs(:,1) = malowess(ybio_ref, yobs,'span',4,'robust',true);

    % find white pt
    yobs(end) = max(prctile (sc.ge(:,ii), 99), yobs(end));  
    
    %check if valid calib curve
    if (any(isnan(yobs)) || any(isinf(yobs)))
        yobsmat(ii,:) = yobs;
        desc{ii} = sprintf('QC_FAIL:%d',sum(diff(yobs)<0));
    else
        qcpass = qcpass + 1;
        qcpass_idx(ii) = true;
        qcrpt(ii).qcpass = true;        
        yobsmat(ii,:) = yobs;
        x = max(sc.ge(:,ii),1);
        
        % Note we only fit the model to a subset of points
        % i.e ignore the white points.        
        cobs = yobs(1:end-2);
        % store calib 
        cal_obs(ii,:) = cobs;
        % reference
        cal_ref(:,1) = ybio_ref(1:end-2);
        % perform linear fit for calib stats
        [wt,bint,r,rint,stats] = regress(cal_ref, x2fx(cobs));
        qcrpt(ii).Calib_slope = wt(2);
        qcrpt(ii).Calib_span = cobs(end) - cobs(1);
        qcrpt(ii).Calib_linfit_Rsquare = stats(1);
        qcrpt(ii).Calib_linfit_pass = stats(3)<0.05;
        
       switch lower(arg.fitmodel)
           case 'pchip'
               % Piecewise cubic hermite interpolating polynomial
               pp = pchip(cobs, cal_ref);                              
               y = ppval(pp, x);
               cal_fit(ii,:) = ppval(pp, cal_obs(ii,:));
               
           case 'spline'
               % Spline interpolation
               sp = spline(cobs, cal_ref);
               y = ppval(sp, x);
               cal_fit(ii, :) = ppval(pp, cobs);
               
         
           case 'linear'
               % Linear least sq fit
               % y = a + bx
               y = x2fx(x) * wt;
               cal_fit(ii, :) = x2fx(cobs) * wt;
               
               qcrpt(ii).Coeff_a = wt(1);
               qcrpt(ii).Coeff_b = wt(2);
               qcrpt(ii).CI_a = print_dlm_line2(num2cellstr(bint(1,:), '-precision',2),'-dlm',',');
               qcrpt(ii).CI_b = print_dlm_line2(num2cellstr(bint(2,:), '-precision',2),'-dlm',',');
               qcrpt(ii).Rsquare = stats(1);
               qcrpt(ii).F = stats(2);
               qcrpt(ii).pvalue = stats(3);
                              
           case 'power'
               % Power model non-linear least sq fit
               % fittype = a*x^b + c
               ft = fittype('power2');
               % get fit obj
               [fobj,gof] = fit(cobs, cal_ref, ft);
               y = feval(fobj, x);
               cal_fit(ii, :) = feval(fobj, cobs);
               
               %coefficients
               qcrpt(ii).Coef_a = fobj.a;
               qcrpt(ii).Coef_b = fobj.b;
               qcrpt(ii).Coef_c = fobj.c;
               % 95% Confidence intervals
               ci = confint(fobj);
               qcrpt(ii).CI_a = print_dlm_line2(num2cellstr(ci(:,1), '-precision',2),'-dlm',',');
               qcrpt(ii).CI_b = print_dlm_line2(num2cellstr(ci(:,2), '-precision',2),'-dlm',',');
               qcrpt(ii).CI_c = print_dlm_line2(num2cellstr(ci(:,3), '-precision',2),'-dlm',',');
               % stats
               qcrpt(ii).Rsquare = gof.rsquare;
               qcrpt(ii).RMSE = gof.rmse;
               
             case 'exp'
               % Exponential model non-linear least sq fit
               % fittype = a*exp(b*x)
               ft = fittype('exp1'); 
               % get fit obj
               [fobj, gof] = fit(cobs, cal_ref, ft);
               y = feval(fobj, x);
               cal_fit(ii, :) = feval(fobj, cobs);
               
               %coefficients
               qcrpt(ii).Coef_a = fobj.a;
               qcrpt(ii).Coef_b = fobj.b;               
               % 95% Confidence intervals
               ci = confint(fobj);
               qcrpt(ii).CI_a = print_dlm_line2(num2cellstr(ci(:,1), '-precision',2),'-dlm',',');
               qcrpt(ii).CI_b = print_dlm_line2(num2cellstr(ci(:,2), '-precision',2),'-dlm',',');
               % stats
               qcrpt(ii).AdjRsquare = gof.adjrsquare;
               qcrpt(ii).RMSE = gof.rmse;               
                              
           otherwise
               error('Unknown fitfun:%s', arg.fitmodel)
       end
       
       % cutoff for thresholding data
       blackpt = arg.minval;
       whitept = arg.maxval;
       % maintain rank ordering of thresholded genes
       top = y>=whitept;
       bot = y<=blackpt;
       minres = 1/(10^arg.precision);       
       y(top) = whitept + minres*rankorder(y(top), 'direc','ascend','zeroindex',true);
       y(bot) = blackpt - minres*rankorder(y(bot), 'direc','descend','zeroindex',true);       
       qcrpt(ii).Truncated_genes = nnz(top) + nnz(bot);
       
       fob.ge(:, qcpass) = y;
            
    end
    if ~mod(ii,100)
        fprintf ('%d/%d\n',ii,numSamples);
    end
end
fprintf ('Normalization complete.\nSamples passed qc: %d/%d\n',qcpass,numSamples);
toc

fob.ge = fob.ge(:,1:qcpass);
fob.sid = fob.sid(qcpass_idx);
levelLabels=['BASE'; calib.gn; 'MOVAVG_1';'MOVAVG_2'];

if arg.debug   
    % yobs, median
    fname = fullfile(wkdir, sprintf('yobs_median_n%dx%d.gct',numSamples, totLevels));
    mkgct(fname, yobsmat_med, sc.sid, desc, strcat(levelLabels,'_MED'), arg.precision);
    
    % yobs, lowess
    fname = fullfile(wkdir, sprintf('yobs_lowess_n%dx%d.gct',numSamples, totLevels));
    mkgct(fname, yobsmat, sc.sid, desc, strcat(levelLabels,'_LOWESS'), arg.precision);
end

% calib curve, observed
fname = fullfile(wkdir, sprintf('calib_n%dx%d.gct',numSamples, totLevels));
mkgct(fname, yobsmat, sc.sid, desc, levelLabels(1:end-2), arg.precision);

% calib curve, fit
fname = fullfile(wkdir, sprintf('calib_fit_n%dx%d.gct',numSamples, totLevels));
mkgct(fname, cal_fit, sc.sid, desc, levelLabels(1:end-2), arg.precision);

% normalized data matrix
[p,f,e] = fileparts(arg.res);
suffix = regexprep(lower(f),'gex_','');
fname_fob = fullfile(wkdir, sprintf('fobv2_%s_%s.gct', arg.fitmodel, suffix));
mkgct(fname_fob, fob.ge, fob.gn, fob.gd, fob.sid, arg.precision);

% samplewise fit report
fname_fitrpt = fullfile(wkdir, sprintf('stats_%s_%s.txt', arg.fitmodel, suffix));
mksin(qcrpt, fname_fitrpt, '-precision', 2);

% report qcfails
if ~isequal(qcpass, numSamples)
    fid = fopen(fullfile(wkdir,'qcfailed_samples.txt'),'wt');
    print_dlm_line2(sc.sid(~qcpass_idx), 'fid',fid, 'dlm', '\n');
    fclose(fid);
end