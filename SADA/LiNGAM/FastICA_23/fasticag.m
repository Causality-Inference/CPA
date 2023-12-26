function fasticag(mixedsig, InitialGuess)
%FASTICAG - Fast Independent Component Analysis, the Graphical User Interface
%
% FASTICAG gives a graphical user interface for performing independent
% component analysis by the FastICA package. No arguments are
% necessary in the function call.
%
% Optional arguments can be given in the form:
% FASTICAG(mixedsig, initialGuess) where the matrix mixedsig contains the
% multidimensional signals as row vectors, and initialGuess gives the
% initial value for the mixing matrix used in the algorithm.
%
% FASTICA uses the fixed-point algorithm developed by Aapo Hyvarinen,
% see http://www.cis.hut.fi/projects/ica/fastica/. The Matlab package was
% programmed by Jarmo Hurri, Hugo Gavert, Jaakko Sarela, and Aapo
% Hyvarinen.
%
%
%   See also FASTICA

% @(#)$Id: fasticag.m,v 1.4 2004/07/27 11:35:29 jarmo Exp $


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global values

% Handle to this main figure
global hf_FastICA_MAIN;

% Check to see if GUI is already running
% Can't have more than one copy - otherwise the global
% variables and handles can get mixed up.
if ~isempty(hf_FastICA_MAIN)
  error('FastICA GUI already running!');
end


% Handles to other controls in this main window
global ht_FastICA_mixedStatus;
global ht_FastICA_dim;
global ht_FastICA_numOfSamp;
global ht_FastICA_newDim;
global ht_FastICA_whiteStatus;
global ht_FastICA_icaStatus;
global hpm_FastICA_approach;
global he_FastICA_numOfIC;
global hpm_FastICA_g;
global hpm_FastICA_stabilization;

% These global variables are used to store all the values
% I used to use the 'UserData' field of components, but
% that got too complex, so I decided to put everything
% in global variables
global g_FastICA_mixedsig;
global g_FastICA_pca_D;
global g_FastICA_pca_E;
global g_FastICA_white_sig;
global g_FastICA_white_wm;
global g_FastICA_white_dwm;
global g_FastICA_ica_sig;
global g_FastICA_ica_A;
global g_FastICA_ica_W;
global g_FastICA_initGuess;
global g_FastICA_approach;
global g_FastICA_numOfIC;
global g_FastICA_g;
global g_FastICA_finetune;
global g_FastICA_a1;
global g_FastICA_a2;
global g_FastICA_myy;
global g_FastICA_stabilization;
global g_FastICA_epsilon;
global g_FastICA_maxNumIte;
global g_FastICA_maxFinetune;
global g_FastICA_sampleSize;
global g_FastICA_initState;
global g_FastICA_displayMo;
global g_FastICA_displayIn;
global g_FastICA_verbose;

% initial values for them:
% All the initial values are set here - even for
% variables that are not used in this file

if nargin < 2
  g_FastICA_initGuess = 1;
  % The user didn't enter initial guess so we default
  % back to random initial state.
  g_FastICA_initState = 1;  % see below for string values
else
  g_FastICA_initGuess = InitialGuess;
  % If initial guess was entered, then the user probably
  % wan't to use it, eh?
  g_FastICA_initState = 2;  % see below for string values
end

if nargin < 1
  g_FastICA_mixedsig = [];
else
  g_FastICA_mixedsig = mixedsig; % We'll remove mean
end                              % the first time we
                                 % use this.

% Global variable for stopping the ICA calculations
global g_FastICA_interrupt;

g_FastICA_pca_D = [];
g_FastICA_pca_E = [];
g_FastICA_white_sig = [];
g_FastICA_white_wm = [];
g_FastICA_white_dwm = [];
g_FastICA_ica_sig = [];
g_FastICA_ica_A = [];
g_FastICA_ica_W = [];
g_FastICA_approach = 1;   % see below for string values
g_FastICA_numOfIC = 0;
g_FastICA_g = 1;          % see below for string values
g_FastICA_finetune = 5;   % see below for string values
g_FastICA_a1 = 1;
g_FastICA_a2 = 1;
g_FastICA_myy = 1;
g_FastICA_stabilization = 2; % see below for string values
g_FastICA_epsilon = 0.0001;
g_FastICA_maxNumIte = 1000;
g_FastICA_maxFinetune = 100;
g_FastICA_sampleSize = 1;
g_FastICA_displayMo = 1;  % see below for string values
g_FastICA_displayIn = 1;
g_FastICA_verbose = 1;    % see below for string values

% These are regarded as constants and are used to store
% the strings for the popup menus the current value is
% seen in the variables above
% D - refers to strings that are displayed
% V - refers to string values that are used in FPICA
global c_FastICA_appr_strD;
global c_FastICA_appr_strV;
global c_FastICA_g1_strD;
global c_FastICA_g1_strV;
global c_FastICA_g2_strD;
global c_FastICA_g2_strV;
global c_FastICA_finetune_strD;
global c_FastICA_finetune_strV;
global c_FastICA_stabili_strD;
global c_FastICA_stabili_strV;
global c_FastICA_iSta_strD;
global c_FastICA_iSta_strV;
global c_FastICA_dMod_strD;
global c_FastICA_dMod_strV;
global c_FastICA_verb_strD;
global c_FastICA_verb_strV;

% All the values for these are set here - even for
% variables that are not used in this file

c_FastICA_appr_strD = 'deflation|symmetric';
c_FastICA_appr_strV = ['defl';'symm'];
% The 'g1' and 'g2' below correspond to the values of approach (1 or 2)
% Deflation and Symmetric used to have a bit different selection
% of available nonlinearities.
c_FastICA_g1_strD = 'pow3|tanh|gauss|skew';
c_FastICA_g1_strV = ['pow3';'tanh';'gaus';'skew'];
c_FastICA_g2_strD = 'pow3|tanh|gauss|skew';
c_FastICA_g2_strV = ['pow3';'tanh';'gaus';'skew'];
c_FastICA_finetune_strD = 'pow3|tanh|gauss|skew|off';
c_FastICA_finetune_strV = ['pow3';'tanh';'gaus';'skew';'off '];
c_FastICA_stabili_strD = 'on|off';
c_FastICA_stabili_strV = ['on ';'off'];
c_FastICA_iSta_strD = 'random|guess';
c_FastICA_iSta_strV = ['rand ';'guess'];
c_FastICA_dMod_strD = 'signals|basis|filters|off';
c_FastICA_dMod_strV = ['signals';'basis  ';'filters';'off    '];
c_FastICA_verb_strD = 'on|off';
c_FastICA_verb_strV = ['on ';'off'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration options
FIGURENAME = 'FastICA';
FIGURETAG = 'f_FastICA';
SCREENSIZE = get(0,'ScreenSize');
FIGURESIZE = [round(0.1*SCREENSIZE(3)) (SCREENSIZE(4)-round(0.1*SCREENSIZE(4))-370) 530 370];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the figure
a = figure('Color',[0.8 0.8 0.8], ...
	   'PaperType','a4letter', ...
	   'Name', FIGURENAME, ...
	   'NumberTitle', 'off', ...
	   'Tag', FIGURETAG, ...
	   'Position', FIGURESIZE, ...
	   'MenuBar', 'none');
% Resizing has to be denied after the window has been created -
% otherwise the window shows only as a tiny window in Windows XP.
set (a, 'Resize', 'off');

hf_FastICA_MAIN = a;

set(hf_FastICA_MAIN, 'HandleVisibility', 'callback');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From here on it get's ugly as I have not had time to clean it up


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the frames
pos_l=2;
pos_w=FIGURESIZE(3)-4;
pos_h=FIGURESIZE(4)-4;
pos_t=FIGURESIZE(4)-2-pos_h;
h_f_background = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'Style','frame', ...
  'Tag','f_background');

pos_l=4;
pos_w=400;
pos_h=106;
pos_t=FIGURESIZE(4)-4-pos_h;
h_f_mixed = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'Style','frame', ...
  'Tag','f_mixed');

pos_h=90;
pos_t=FIGURESIZE(4)-(106+4+2)-pos_h;
h_f_white = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'Style','frame', ...
  'Tag','f_white');

pos_h=pos_t - 4 - 2;
pos_t=4;
h_f_ica = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'Style','frame', ...
  'Tag','f_ica');

pos_w=120;
pos_l=FIGURESIZE(3)-(pos_w+2+2);
pos_h=FIGURESIZE(4)-2*4;
pos_t=FIGURESIZE(4)-(4)-pos_h;
h_f_side = uicontrol('Parent',a, ...
  'BackgroundColor',[0.5 0.5 0.5], ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'Style','frame', ...
  'Tag','f_side');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Controls in f_mixed
bgc = get(h_f_mixed, 'BackgroundColor');

pos_vspace = 6;
pos_hspace = 6;

pos_frame=get(h_f_mixed, 'Position');
pos_l = pos_frame(1) + 6;
pos_h = 16;
pos_t = pos_frame(2) + pos_frame(4) - pos_h - 6;
pos_w = 150;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Mixed signals:', ...
  'FontWeight', 'bold', ...
  'Style','text', ...
  'Tag','t_mixed');

pos_l = pos_l + pos_w;
pos_w = 120;
ht_FastICA_mixedStatus = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Not loaded yet', ...
  'Style','text', ...
  'Tag','t_mixedstatus');

% V�h�n v�li�
pos_t = pos_t - 8;

pos_l = pos_frame(1) + 6;
pos_t = pos_t - pos_h;
pos_w = 150;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Number of signals:', ...
  'Style','text', ...
  'Tag','t_2');

pos_l = pos_l + pos_w;
pos_w = 50;
ht_FastICA_dim = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','', ...
  'Style','text', ...
  'Tag','t_dim');

pos_l = pos_frame(1) + 6;
pos_t = pos_t - pos_h;
pos_w = 150;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Number of samples:', ...
  'Style','text', ...
  'Tag','t_3');

pos_l = pos_l + pos_w;
pos_w = 50;
ht_FastICA_numOfSamp = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','', ...
  'Style','text', ...
  'Tag','t_numOfSamp');


% Buttons
pos_l = pos_frame(1) + pos_hspace;
pos_w = 110;
pos_h = 30;
pos_t = pos_frame(2) + pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb Transpose', ...
  'Interruptible', 'off', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Transpose', ...
  'Tag','b_Transpose');

pos_w = 130;
pos_l = pos_frame(1) + pos_frame(3) - pos_hspace - pos_w;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb ShowMixed', ...
  'Interruptible', 'off', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Plot data', ...
  'Tag','b_ShowMixed');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Controls in f_white
pos_frame=get(h_f_white, 'Position');
pos_l = pos_frame(1) + 6;
pos_h = 16;
pos_t = pos_frame(2) + pos_frame(4) - pos_h - 6;
pos_w = 150;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Dimension control:', ...
  'FontWeight', 'bold', ...
  'Style','text', ...
  'Tag','t_white');

pos_l = pos_l + pos_w;
pos_w = 120;
ht_FastICA_whiteStatus = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','', ...
  'Style','text', ...
  'Tag','t_whiteStatus');

% V�h�n v�li�
pos_t = pos_t - 8;

pos_l = pos_frame(1) + 6;
pos_t = pos_t - pos_h;
pos_w = 150;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Reduced dimension:', ...
  'Style','text', ...
  'Tag','t_4');

pos_l = pos_l + pos_w;
pos_w = 50;
ht_FastICA_newDim = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','', ...
  'Style','text', ...
  'Tag','t_newDim');


% buttons

pos_l = pos_frame(1) + pos_hspace;
pos_w = 110;
pos_h = 30;
pos_t = pos_frame(2) + pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb DoPCA', ...
  'Interruptible', 'off', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Reduce dim.', ...
  'Tag','b_DoPCA');

pos_l = pos_l + pos_w + pos_hspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb OrigDim', ...
  'Interruptible', 'off', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Original dim.', ...
  'Tag','b_OrigDim');

pos_w = 130;
pos_h = 30;
pos_l = pos_frame(1) + pos_frame(3) - 6 - pos_w;
pos_t = pos_frame(2) + 6;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb ShowWhite', ...
  'Interruptible', 'off', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Plot whitened', ...
  'Tag','b_ShowWhite');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Controls in f_ica
pos_frame=get(h_f_ica, 'Position');
pos_l = pos_frame(1) + 6;
pos_h = 20;
pos_t = pos_frame(2) + pos_frame(4) - pos_h - 6;
pos_w = 150;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Fixed point ICA:', ...
  'FontWeight', 'bold', ...
  'Style','text', ...
  'Tag','t_white');

pos_l = pos_l + pos_w;
pos_w = 120;
ht_FastICA_icaStatus = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Not yet done', ...
  'Style','text', ...
  'Tag','t_icaStatus');

% V�h�n v�li�
pos_t = pos_t - 8;

%pos_l = pos_frame(1) + 6;
pos_l = pos_frame(1) + 6 + 150;
pos_t = pos_t - pos_h;
%pos_w = 260;
pos_w = 120;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Approach:', ...
  'Style','text', ...
  'Tag','t_5');

pos_w = 100;
%pos_t = pos_t - 4;
pos_l = pos_frame(1) + pos_frame(3) - 6 - pos_w;
hpm_FastICA_approach = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'Callback','gui_cb ChangeApproach', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String',c_FastICA_appr_strD, ...
  'Style','popupmenu', ...
  'Tag','pm_approach', ...
  'Value',g_FastICA_approach);

%pos_t = pos_t - 4;
%pos_l = pos_frame(1) + 6;
pos_l = pos_frame(1) + 6 + 150;
pos_t = pos_t - pos_h;
%pos_w = 260;
pos_w = 120;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Number of ICs:', ...
  'Style','text', ...
  'Tag','t_6');

pos_w = 100;
pos_l = pos_frame(1) + pos_frame(3) - 6 - pos_w;
he_FastICA_numOfIC = uicontrol('Parent',a, ...
  'BackgroundColor',[1 1 1], ...
  'Callback','gui_cb ChangeNumOfIC', ...
  'HorizontalAlignment','right', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','0', ...
  'Style','edit', ...
  'Tag','e_numOfIC');

%pos_t = pos_t - 4;
%pos_l = pos_frame(1) + 6;
pos_l = pos_frame(1) + 6 + 150;
pos_t = pos_t - pos_h;
%pos_w = 260;
pos_w = 120;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Nonlinearity (g):', ...
  'Style','text', ...
  'Tag','t_71');

%pos_t = pos_t - 4;
pos_w = 100;
pos_l = pos_frame(1) + pos_frame(3) - 6 - pos_w;
hpm_FastICA_g = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'Callback','gui_cb ChangeG', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String',c_FastICA_g1_strD, ...
  'Style','popupmenu', ...
  'Tag','pm_g', ...
  'Value',g_FastICA_g);

%pos_t = pos_t - 4;
%pos_l = pos_frame(1) + 6;
pos_l = pos_frame(1) + 6 + 150;
pos_t = pos_t - pos_h;
%pos_w = 260;
pos_w = 120;
b = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'HorizontalAlignment','left', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Stabilization:', ...
  'Style','text', ...
  'Tag','t_71a');

%pos_t = pos_t - 4;
pos_w = 100;
pos_l = pos_frame(1) + pos_frame(3) - 6 - pos_w;
hpm_FastICA_stabilization = uicontrol('Parent',a, ...
  'BackgroundColor',bgc, ...
  'Callback','gui_cb ChangeStab', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String',c_FastICA_stabili_strD, ...
  'Style','popupmenu', ...
  'Tag','pm_stab', ...
  'Value',g_FastICA_stabilization);



pos_l = pos_frame(1) + pos_vspace;
pos_w = 110;
pos_h = 30;
pos_t = pos_frame(2) + pos_hspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb AdvOpt', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Adv. options >>', ...
  'Tag','b_advOpt');

pos_w = 130;
pos_h = 30;
pos_l = pos_frame(1) + pos_frame(3) - pos_vspace - pos_w;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb ShowICASig', ...
  'Interruptible', 'on', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Plot ICs', ...
  'Tag','b_ShowICASig');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Controls in f_side
pos_vspace = 6;
pos_hspace = 10;
pos_temp=get(h_f_side, 'Position');
pos_l=pos_temp(1)+pos_hspace;
pos_w=100;
pos_h=30;
pos_t=pos_temp(2)+pos_temp(4)-pos_vspace-pos_h;

b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb LoadData', ...
  'Interruptible', 'off', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Load data', ...
  'Tag','b_LoadData');


pos_t=pos_t-pos_h-pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb DoFPICA', ...
  'Interruptible', 'on', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Do ICA', ...
  'Tag','b_DoFPICA');

pos_t=pos_t-pos_h-pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb SaveData', ...
  'Interruptible', 'off', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Save results', ...
  'Tag','b_SaveData');

pos_t=pos_t-pos_h-pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb Quit', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Quit', ...
  'Tag','b_Quit');

pos_t=pos_t-pos_h-pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb Interrupt', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Interrupt', ...
  'Visible','off', ...
  'Tag','b_Interrupt');

pos_t = pos_frame(2) + pos_vspace + pos_h + pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb About', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','About...', ...
  'Tag','b_About');

pos_t = pos_frame(2) + pos_vspace;
b = uicontrol('Parent',a, ...
  'BackgroundColor',[0.701961 0.701961 0.701961], ...
  'Callback','gui_cb Help', ...
  'Position',[pos_l pos_t pos_w pos_h], ...
  'String','Help', ...
  'Tag','b_Help');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do rest of the initialization...
  gui_cb InitAll;

