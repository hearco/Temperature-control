// pidgui.sce
// Graphical User Interface for PID controller
// Dew Toochinda, August 2014

funcprot(0);
xdel(winsid());
global kp ki kd setPoint stepValue;
global eb_kp sl_kp eb_ki sl_ki eb_kd sl_kd ;
global eb_stepValue sl_stepValue eb_setPoint sl_setPoint;
global NumGc DenGc;
global z TimeValue;
global eb_TimeValue sl_TimeValue;
global ManualEnable FirstPIDEnable SecondPIDEnable DahlinEnable PersonalizadoEnable;
global temp_ManualEnable temp_FirstPIDEnable temp_SecondPIDEnable temp_DahlinEnable temp_PersonalizadoEnable;
global FPPButton DahlinButton SecondPIDButton FirstPIDButton ManualModeButton;

temp_ManualEnable = 0;
    
temp_FirstPIDEnable = 1;
    
temp_SecondPIDEnable = 0;
 
temp_DahlinEnable = 0;
        
temp_PersonalizadoEnable = 0;

// ************** set parameter ranges here ***************************
kpmax = 50;
kpmin = 0.001;
kimax = 100;
kimin = 0.001;
kdmax = 10;
kdmin = 0.001;
TimeValueMax = 10;
TimeValueMin = 0.1;

stepValueMax = 100;
stepValueMin = 0;

setPointMax = 50;
setPointMin = 30;

//NumGc = kp * z * (ki * kd * (z - 1) * (z - 1) + ki * (z - 1) * z + (z * z) );
//DenGc = ki * (z - 1) * (z * z);

// PID Equations
NumGc = kp * z * TimeValue *  (ki * kd * (z - 1)^2 + ki *  (z - 1) * (z * TimeValue) + (z^2 * TimeValue^2) );
DenGc = ki * (z - 1) * (z^2 * TimeValue^2);

//*********************************************************************

// ****************set default parameter values here ********************
//kp = 20.1658;  // proportional gain
//ki = 38.365;  // integral gain
//kd = 1.939;   // derivative gain
//setPoint = 40;
//stepValue = 20;
//TimeValue = 3;


// ****************set default parameter values here ********************
kp = 7.996;  // proportional gain
ki = 29.331;  // integral gain
kd = 0.401;   // derivative gain
setPoint = 30;
stepValue = 20;
TimeValue = 3;

// ************* set controller status
ManualEnable = 0;
FirstPIDEnable = 1;
SecondPIDEnable = 0;
DahlinEnable = 0;
PersonalizadoEnable = 0;

//****************************************************************************

// --- common component height and widths -----
hrow = 0.05;
wlabel = 0.05;
wlabel2 = 0.25;
wlabel3 = 0.3;
wsliderl = 0.4;
wsliders = 0.3;
wedit = 0.15;
rowspace = hrow+0.01;
row1 = 0.8;  // row group 1
row2 = 0.5;  // row group 2
lmargin = 0.02;
lslider = 0.1;
ledit1 = 0.52;
ledit2 = 0.42;
ltext1 = 0.7;
ltext2 = 0.65;

mywin = createWindow();
mywin.Position = [0 0 400 400];


// ----- PID text -------------------
pidlabel=uicontrol(mywin,"style","text");
pidlabel.Units="normalized";
pidlabel.Position = [0.2 0.88 0.4 0.05];
pidlabel.String = "PID parameters";
pidlabel.BackgroundColor = [0.8,0.8,0.8];
pidlabel.FontSize = 18;
pidlabel.ForegroundColor = [0.7,0,0];

// *********** Kp control *****************************
// ----- kp slider -------------
function updateslider_kp(sl_kp)
   global eb_kp;
   eb_kp.Value = sl_kp.Value;
   eb_kp.String = msprintf('%5.3f',eb_kp.Value);
  
endfunction


sl_kp=uicontrol(mywin, "style","slider");
sl_kp.Min=kpmin;
sl_kp.Max=kpmax;
sl_kp.Value=kp;
sl_kp.Units="normalized";
sl_kp.Position=[lslider row1 wsliderl hrow];
sl_kp.Callback="updateslider_kp";

// ----- left text -----
kplabel=uicontrol(mywin,"style","text");
kplabel.Units="normalized";
kplabel.Position = [lmargin row1 wlabel hrow];
kplabel.String = "$K_p$";
kplabel.BackgroundColor = [0.8,0.8,0.8];
// ---- right edit box ----
function updateedit_kp(eb_kp)
    global sl_kp eb_kp;
    eb_kp.Value = eval(eb_kp.String);
    if (eb_kp.Value < kpmin)
        disp('Kp value below range. Set to minimum');
        eb_kp.Value = kpmin;
        eb_kp.String = msprintf('%5.3f',eb_kp.Value);
    elseif (eb_kp.Value > kpmax)
        disp('Kp value above range. Set to maximum');
        eb_kp.Value = kpmax;
        eb_kp.String = msprintf('%5.3f',eb_kp.Value);            
    end
    sl_kp.Value = eb_kp.Value;
endfunction

eb_kp=uicontrol(mywin,"style","edit");
eb_kp.String = msprintf('%5.3f',kp);
eb_kp.Value = kp;
eb_kp.Units="normalized";
eb_kp.Position=[ledit1 row1 wedit hrow];
eb_kp.Callback = "updateedit_kp";

// ----- right text -----
kplabelr=uicontrol(mywin,"style","text");
kplabelr.Units="normalized";
kplabelr.Position = [ltext1 row1 wlabel2 hrow];
kplabelr.String = "Proportional gain";
kplabelr.BackgroundColor = [0.8,0.8,0.8];
kplabelr.ForegroundColor = [0.5,0,0];

// *********** Ki control *****************************
// ----- ki slider -------------
function updateslider_ki(sl_ki)
   global eb_ki;
   eb_ki.Value = sl_ki.Value;
   eb_ki.String = msprintf('%5.3f',eb_ki.Value);
  //ki = sl_ki.Value;
endfunction


sl_ki=uicontrol(mywin, "style","slider");
sl_ki.Min=kimin;
sl_ki.Max=kimax;
sl_ki.Value=ki;
sl_ki.Units="normalized";
sl_ki.Position=[lslider row1-rowspace wsliderl hrow];
sl_ki.Callback="updateslider_ki";

// ----- left text -----
kilabel=uicontrol(mywin,"style","text");
kilabel.Units="normalized";
kilabel.Position = [lmargin row1-rowspace wlabel hrow];
kilabel.String = "$K_i$";
kilabel.BackgroundColor = [0.8,0.8,0.8];
// ---- right edit box ----
function updateedit_ki(eb_ki)
    global sl_ki eb_ki;
    eb_ki.Value = eval(eb_ki.String);
    if (eb_ki.Value < kimin)
        disp('ki value below range. Set to minimum');
        eb_ki.Value = kimin;
        eb_ki.String = msprintf('%5.3f',eb_ki.Value);
    elseif (eb_ki.Value > kimax)
        disp('ki value above range. Set to maximum');
        eb_ki.Value = kimax;
        eb_ki.String = msprintf('%5.3f',eb_ki.Value);            
    end
    sl_ki.Value = eb_ki.Value;
endfunction

eb_ki=uicontrol(mywin,"style","edit");
eb_ki.String = msprintf('%5.3f',ki);
eb_ki.Value = ki;
eb_ki.Units="normalized";
eb_ki.Position=[ledit1 row1-rowspace wedit hrow];
eb_ki.Callback = "updateedit_ki";

// ----- right text -----
kilabelr=uicontrol(mywin,"style","text");
kilabelr.Units="normalized";
kilabelr.Position = [ltext1 row1-rowspace wlabel2 hrow];
kilabelr.String = "Integral gain";
kilabelr.BackgroundColor = [0.8,0.8,0.8];
kilabelr.ForegroundColor = [0.5,0,0];

// *********** Kd control *****************************
// ----- kd slider -------------
function updateslider_kd(sl_kd)
   global eb_kd;
   eb_kd.Value = sl_kd.Value;
   eb_kd.String = msprintf('%5.3f',eb_kd.Value);
  
endfunction


sl_kd=uicontrol(mywin, "style","slider");
sl_kd.Min=kdmin;
sl_kd.Max=kdmax;
sl_kd.Value=kd;
sl_kd.Units="normalized";
sl_kd.Position=[lslider row1-2*rowspace wsliderl hrow];
sl_kd.Callback="updateslider_kd";

// ----- left text -----
kdlabel=uicontrol(mywin,"style","text");
kdlabel.Units="normalized";
kdlabel.Position = [lmargin row1-2*rowspace wlabel hrow];
kdlabel.String = "$K_d$";
kdlabel.BackgroundColor = [0.8,0.8,0.8];
// ---- right edit box ----
function updateedit_kd(eb_kd)
    global sl_kd eb_kd;
    eb_kd.Value = eval(eb_kd.String);
    if (eb_kd.Value < kdmin)
        disp('kd value below range. Set to minimum');
        eb_kd.Value = kdmin;
        eb_kd.String = msprintf('%5.3f',eb_kd.Value);
    elseif (eb_kd.Value > kdmax)
        disp('kd value above range. Set to maximum');
        eb_kd.Value = kdmax;
        eb_kd.String = msprintf('%5.3f',eb_kd.Value);            
    end
    sl_kd.Value = eb_kd.Value;
endfunction

eb_kd=uicontrol(mywin,"style","edit");
eb_kd.String = msprintf('%5.3f',kd);
eb_kd.Value = kd;
eb_kd.Units="normalized";
eb_kd.Position=[ledit1 row1-2*rowspace wedit hrow];
eb_kd.Callback = "updateedit_kd";

// ----- right text -----
kdlabelr=uicontrol(mywin,"style","text");
kdlabelr.Units="normalized";
kdlabelr.Position = [ltext1 row1-2*rowspace wlabel2 hrow];
kdlabelr.String = "Derivative gain";
kdlabelr.BackgroundColor = [0.8,0.8,0.8];
kdlabelr.ForegroundColor = [0.5,0,0];

// *********** Step Value control *****************************
// ----- Step slider -------------
function updateslider_stepValue(sl_stepValue)
   global eb_stepValue;
   eb_stepValue.Value = sl_stepValue.Value;
   eb_stepValue.String = msprintf('%5.3f',eb_stepValue.Value);
  
endfunction


sl_stepValue = uicontrol(mywin, "style","slider");
sl_stepValue.Min = stepValueMin;
sl_stepValue.Max = stepValueMax;
sl_stepValue.Value = stepValue;
sl_stepValue.Units="normalized";
sl_stepValue.Position=[lslider row1-3*rowspace wsliderl hrow];
sl_stepValue.Callback="updateslider_stepValue";

// ----- left text -----
stepValuelabel=uicontrol(mywin,"style","text");
stepValuelabel.Units="normalized";
stepValuelabel.Position = [lmargin row1-3*rowspace wlabel hrow];
stepValuelabel.String = "$U_z$";
stepValuelabel.BackgroundColor = [0.8,0.8,0.8];
// ---- right edit box ----
function updateedit_stepValue(eb_stepValue)
    global sl_stepValue eb_stepValue;
    eb_stepValue.Value = eval(eb_stepValue.String);
    if (eb_stepValue.Value < stepValueMin)
        disp('kd value below range. Set to minimum');
        eb_stepValue.Value = stepValueMin;
        eb_stepValue.String = msprintf('%5.3f',eb_stepValue.Value);
    elseif (eb_stepValue.Value > stepValueMax)
        disp('kd value above range. Set to maximum');
        eb_stepValue.Value = stepValueMax;
        eb_stepValue.String = msprintf('%5.3f',eb_stepValue.Value);            
    end
    sl_stepValue.Value = eb_stepValue.Value;
endfunction

eb_stepValue = uicontrol(mywin,"style","edit");
eb_stepValue.String = msprintf('%5.3f',stepValue);
eb_stepValue.Value = stepValue;
eb_stepValue.Units="normalized";
eb_stepValue.Position=[ledit1 row1-3*rowspace wedit hrow];
eb_stepValue.Callback = "updateedit_stepValue";

// ----- right text -----
stepValuelabelr=uicontrol(mywin,"style","text");
stepValuelabelr.Units="normalized";
stepValuelabelr.Position = [ltext1 row1-3*rowspace wlabel2 hrow];
stepValuelabelr.String = "Escalon (%)";
stepValuelabelr.BackgroundColor = [0.8,0.8,0.8];
stepValuelabelr.ForegroundColor = [0.5,0,0];


// *********** Set Point control *****************************
// ----- Set Point slider -------------
function updateslider_setPoint(sl_setPoint)
   global eb_setPoint;
   eb_setPoint.Value = sl_setPoint.Value;
   eb_setPoint.String = msprintf('%5.3f',eb_setPoint.Value);
  
endfunction


sl_setPoint = uicontrol(mywin, "style","slider");
sl_setPoint.Min = setPointMin;
sl_setPoint.Max = setPointMax;
sl_setPoint.Value = setPoint;
sl_setPoint.Units="normalized";
sl_setPoint.Position=[lslider row1-4*rowspace wsliderl hrow];
sl_setPoint.Callback="updateslider_setPoint";

// ----- left text -----
setPointlabel=uicontrol(mywin,"style","text");
setPointlabel.Units="normalized";
setPointlabel.Position = [lmargin row1-4*rowspace wlabel hrow];
setPointlabel.String = "$R_z$";
setPointlabel.BackgroundColor = [0.8,0.8,0.8];
// ---- right edit box ----
function updateedit_setPoint(eb_setPoint)
    global sl_setPoint eb_setPoint;
    eb_setPoint.Value = eval(eb_setPoint.String);
    if (eb_setPoint.Value < setPointMin)
        disp('kd value below range. Set to minimum');
        eb_setPoint.Value = setPointMin;
        eb_setPoint.String = msprintf('%5.3f',eb_setPoint.Value);
    elseif (eb_setPoint.Value > setPointMax)
        disp('kd value above range. Set to maximum');
        eb_setPoint.Value = setPointMax;
        eb_setPoint.String = msprintf('%5.3f',eb_setPoint.Value);            
    end
    sl_setPoint.Value = eb_setPoint.Value;
endfunction

eb_setPoint = uicontrol(mywin,"style","edit");
eb_setPoint.String = msprintf('%5.3f',setPoint);
eb_setPoint.Value = setPoint;
eb_setPoint.Units="normalized";
eb_setPoint.Position=[ledit1 row1-4*rowspace wedit hrow];
eb_setPoint.Callback = "updateedit_setPoint";

// ----- right text -----
setPointlabelr=uicontrol(mywin,"style","text");
setPointlabelr.Units="normalized";
setPointlabelr.Position = [ltext1 row1-4*rowspace wlabel2 hrow];
setPointlabelr.String = "Set Point (°C)";
setPointlabelr.BackgroundColor = [0.8,0.8,0.8];
setPointlabelr.ForegroundColor = [0.5,0,0];



// *********** Time control *****************************
// ----- Time Value slider -------------
function updateslider_TimeValue(sl_TimeValue)
   global eb_TimeValue;
   eb_TimeValue.Value = sl_TimeValue.Value;
   eb_TimeValue.String = msprintf('%5.3f',eb_TimeValue.Value);
  
endfunction


sl_TimeValue = uicontrol(mywin, "style","slider");
sl_TimeValue.Min = TimeValueMin;
sl_TimeValue.Max = TimeValueMax;
sl_TimeValue.Value = TimeValue;
sl_TimeValue.Units="normalized";
sl_TimeValue.Position=[lslider row1-5*rowspace wsliderl hrow];
sl_TimeValue.Callback="updateslider_TimeValue";

// ----- left text -----
TimeValuelabel=uicontrol(mywin,"style","text");
TimeValuelabel.Units="normalized";
TimeValuelabel.Position = [lmargin row1-5*rowspace wlabel hrow];
TimeValuelabel.String = "$T$";
TimeValuelabel.BackgroundColor = [0.8,0.8,0.8];
// ---- right edit box ----
function updateedit_TimeValue(eb_TimeValue)
    global sl_TimeValue eb_TimeValue;
    eb_TimeValue.Value = eval(eb_TimeValue.String);
    if (eb_TimeValue.Value < TimeValueMin)
        disp('kd value below range. Set to minimum');
        eb_TimeValue.Value = TimeValueMin;
        eb_TimeValue.String = msprintf('%5.3f',eb_TimeValue.Value);
    elseif (eb_TimeValue.Value > TimeValueMax)
        disp('kd value above range. Set to maximum');
        eb_TimeValue.Value = TimeValueMax;
        eb_TimeValue.String = msprintf('%5.3f',eb_TimeValue.Value);            
    end
    sl_TimeValue.Value = eb_TimeValue.Value;
endfunction

eb_TimeValue = uicontrol(mywin,"style","edit");
eb_TimeValue.String = msprintf('%5.3f',TimeValue);
eb_TimeValue.Value = TimeValue;
eb_TimeValue.Units="normalized";
eb_TimeValue.Position=[ledit1 row1-5*rowspace wedit hrow];
eb_TimeValue.Callback = "updateedit_TimeValue";

// ----- right text -----
TimeValuer=uicontrol(mywin,"style","text");
TimeValuer.Units="normalized";
TimeValuer.Position = [ltext1 row1 - 5 * rowspace wlabel2 hrow];
TimeValuer.String = "Time";
TimeValuer.BackgroundColor = [0.8,0.8,0.8];
TimeValuer.ForegroundColor = [0.5,0,0];

// ***************** Select controller *****************************
// ----- Manual mode ----------------
function selectManualMode (ManualModeButton)
    global temp_ManualEnable temp_FirstPIDEnable temp_SecondPIDEnable temp_DahlinEnable temp_PersonalizadoEnable;
    global FPPButton DahlinButton SecondPIDButton FirstPIDButton ManualModeButton;
    
    temp_ManualEnable = 1;
    ManualModeButton.Value = 1;
    
    temp_FirstPIDEnable = 0;
    FirstPIDButton.Value = 0;
    
    temp_SecondPIDEnable = 0;
    SecondPIDButton.Value = 0;
    
    temp_DahlinEnable = 0;
    DahlinButton.Value = 0;
    
    temp_PersonalizadoEnable = 0;
    FPPButton.Value = 0;

endfunction

ManualModeButton = uicontrol(mywin, "style", "radiobutton");
ManualModeButton.Position = [15 150 140 20];
ManualModeButton.String = "Manual";
ManualModeButton.Value = ManualEnable;
ManualModeButton.Callback = "selectManualMode";

// ----- PID 1 criterio ----------------
function selectFirstPID(FirstPIDButton)
    global temp_ManualEnable temp_FirstPIDEnable temp_SecondPIDEnable temp_DahlinEnable temp_PersonalizadoEnable;
    global FPPButton DahlinButton SecondPIDButton FirstPIDButton ManualModeButton;
    global kp ki kd;
    global sl_kp eb_kp sl_ki eb_ki sl_kd eb_kd;
    
    temp_ManualEnable = 0;
    ManualModeButton.Value = 0;
    
    temp_FirstPIDEnable = 1;
    FirstPIDButton.Value = 1;
    
    temp_SecondPIDEnable = 0;
    SecondPIDButton.Value = 0;
    
    temp_DahlinEnable = 0;
    DahlinButton.Value = 0;
    
    temp_PersonalizadoEnable = 0;
    FPPButton.Value = 0;
    
    sl_kp.Value = 7.996;
    eb_kp.Value = 7.996;
    eb_kp.String = msprintf('%5.3f',7.996);  
  
    sl_ki.Value = 29.331;
    eb_ki.Value = 29.331;
    eb_ki.String = msprintf('%5.3f',29.331);    
  
    sl_kd.Value = 0.401;
    eb_kd.Value = 0.401;
    eb_kd.String = msprintf('%5.3f',0.401);
    
    kp = 7.996;
    ki = 29.331;
    kd = 0.401
    
endfunction

FirstPIDButton = uicontrol(mywin, "style", "radiobutton");
FirstPIDButton.Position = [15 130 140 20];
FirstPIDButton.String = "PID 2";
FirstPIDButton.Value = FirstPIDEnable;
FirstPIDButton.Callback = "selectFirstPID";

// ------ PID 2 criterios ---------------
function selectSecondPID(SecondPIDButton)
   global temp_ManualEnable temp_FirstPIDEnable temp_SecondPIDEnable temp_DahlinEnable temp_PersonalizadoEnable;
   global FPPButton DahlinButton SecondPIDButton FirstPIDButton ManualModeButton;
   global kp ki kd;
   global sl_kp eb_kp sl_ki eb_ki sl_kd eb_kd;
    
    temp_ManualEnable = 0;
    ManualModeButton.Value = 0;
    
    temp_FirstPIDEnable = 0;
    FirstPIDButton.Value = 0;
    
    temp_SecondPIDEnable = 1;
    SecondPIDButton.Value = 1;
    
    temp_DahlinEnable = 0;
    DahlinButton.Value = 0;
    
    temp_PersonalizadoEnable = 0;
    FPPButton.Value = 0;
    
    sl_kp.Value = 3.336;
    eb_kp.Value = 3.336;
    eb_kp.String = msprintf('%5.3f',3.336);  
  
    sl_ki.Value = 48.671;
    eb_ki.Value = 48.671;
    eb_ki.String = msprintf('%5.3f',48.671);    
  
    sl_kd.Value = 0.401;
    eb_kd.Value = 0.401;
    eb_kd.String = msprintf('%5.3f',0.401);
    
    kp = 3.336;
    ki = 48.671;
    kd = 0.401;
    
endfunction

SecondPIDButton = uicontrol(mywin, "style", "radiobutton");
SecondPIDButton.Position = [15 110 140 20];
SecondPIDButton.String = "PID 1";
SecondPIDButton.Value = SecondPIDEnable;
SecondPIDButton.Callback = "selectSecondPID";

// ------ Dahlin ---------------
function selectDahlin(DahlinButton)
    global temp_ManualEnable temp_FirstPIDEnable temp_SecondPIDEnable temp_DahlinEnable temp_PersonalizadoEnable;
    global FPPButton DahlinButton SecondPIDButton FirstPIDButton ManualModeButton;
    
    temp_ManualEnable = 0;
    ManualModeButton.Value = 0;
    
    temp_FirstPIDEnable = 0;
    FirstPIDButton.Value = 0;
    
    temp_SecondPIDEnable = 0;
    SecondPIDButton.Value = 0;
    
    temp_DahlinEnable = 1;
    DahlinButton.Value = 1;
    
    temp_PersonalizadoEnable = 0;
    FPPButton.Value = 0;
    
endfunction

DahlinButton = uicontrol(mywin, "style", "radiobutton");
DahlinButton.Position = [15 90 140 20];
DahlinButton.String = "Dahlin";
DahlinButton.Value = DahlinEnable;
DahlinButton.Callback = "selectDahlin";

// -------- Personalizado ---------
function selectPersonalizado(FPPButton)
    global temp_ManualEnable temp_FirstPIDEnable temp_SecondPIDEnable temp_DahlinEnable temp_PersonalizadoEnable;
    global FPPButton DahlinButton SecondPIDButton FirstPIDButton ManualModeButton;
    
    temp_ManualEnable = 0;
    ManualModeButton.Value = 0;
    
    temp_FirstPIDEnable = 0;
    FirstPIDButton.Value = 0;
    
    temp_SecondPIDEnable = 0;
    SecondPIDButton.Value = 0;
    
    temp_DahlinEnable = 0;
    DahlinButton.Value = 0;
    
    temp_PersonalizadoEnable = 1;
    FPPButton.Value = 1;
    
endfunction

FPPButton = uicontrol(mywin, "style", "radiobutton");
FPPButton.Position = [15 70 140 20];
FPPButton.String = "Personalizado";
FPPButton.Value = PersonalizadoEnable;
FPPButton.Callback = "selectPersonalizado";

// ****************** Update/Restore button control ******************
// ------- update button
function updateparm (updatebutton )
  global kp ki kd stepValue setPoint;
  global temp_ManualEnable temp_FirstPIDEnable temp_SecondPIDEnable temp_DahlinEnable temp_PersonalizadoEnable;
  global ManualEnable FirstPIDEnable SecondPIDEnable DahlinEnable PersonalizadoEnable;
  global TimeValue;
  
  kp = eb_kp.Value;
  ki = eb_ki.Value;
  kd = eb_kd.Value;
  
  stepValue = eb_stepValue.Value;
  setPoint = eb_setPoint.Value;
  TimeValue = eb_TimeValue.Value;

  ManualEnable = temp_ManualEnable;
  FirstPIDEnable = temp_FirstPIDEnable;
  SecondPIDEnable = temp_SecondPIDEnable;
  DahlinEnable = temp_DahlinEnable;
  PersonalizadoEnable = temp_PersonalizadoEnable;

endfunction


updatebutton = uicontrol(mywin,"style","pushbutton");
updatebutton.Units = "normalized";
updatebutton.Position = [0.05 0.01 0.2 0.08];
updatebutton.String = "Update";
updatebutton.BackgroundColor=[0.9 0.9 0.9];
updatebutton.Callback = "updateparm";
updatebutton.Relief="raised";


// ------- restore button
function restoreparm (restorebutton )
  global sl_kp eb_kp sl_ki eb_ki sl_kd eb_kd sl_N eb_N;
  global sl_kt eb_kt sl_wp eb_wp sl_wd eb_wd eb_llim eb_ulim;
  global TimeValue sl_TimeValue eb_TimeValue;

  sl_kp.Value = 7.996;
  eb_kp.Value = 7.996;
  eb_kp.String = msprintf('%5.3f',7.996);  
  
  sl_ki.Value = 29.331;
  eb_ki.Value = 29.331;
  eb_ki.String = msprintf('%5.3f',29.331);    
  
  sl_kd.Value = 0.401;
  eb_kd.Value = 0.401;
  eb_kd.String = msprintf('%5.3f',0.401);   
  
  sl_stepValue.Value = stepValue;
  eb_stepValue.Value = stepValue;
  eb_stepValue.String = msprintf('%5.3f',stepValue);
  
  sl_setPoint.Value = setPoint;
  eb_setPoint.Value = setPoint;
  eb_setPoint.String = msprintf('%5.3f',setPoint);
  
  sl_TimeValue.Value = 3;
  eb_TimeValue.Value = 3;
  eb_TimeValue.String = msprintf('%5.3f', 3);
  
endfunction


restorebutton=uicontrol(mywin,"style","pushbutton");
restorebutton.Units = "normalized";
restorebutton.Position = [0.3 0.01 0.2 0.08];
restorebutton.String = "Restore";
restorebutton.BackgroundColor=[0.9 0.9 0.9];
restorebutton.Callback = "restoreparm";
restorebutton.Relief="raised";


