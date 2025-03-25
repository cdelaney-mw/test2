%[text] Model and add aerodynamic coefficients and constraints to the optimization problem.
function [aircraft, wing, fuselage, hTail, vTail, designprob] = ...
        addAerodynamics(aircraft, wing, fuselage, hTail, vTail, designprob)
%[text] ## Wing Aerodynamics
%[text] Use Prandtl lifing-line theory to estimate the wing's lift and drag coefficients. This theory is valid for wings of high enough aspect ratio, and so requires some additional constraints.
numcoeff = 10;
B = fcn2optimexpr(@PrandtlCoefficients,wing.HalfSpan,...
    wing.RootChord,wing.TaperRatio,wing.Airfoil, ...
    numcoeff,'OutputSize',[numcoeff,1],'ReuseEvaluation',true);             % Prandtl Lifting Line Coefficients
wing.ClAlpha = B(1)*pi*wing.AspectRatio;                                    % Lift Slope
wing.Cd0 = wing.Airfoil.Cd0;                                                % Parasitic Drag
wing.K = (1:2:2*numcoeff-1)*(B./B(1)).^2 ...
                /(pi*wing.AspectRatio);                                     % Induced Drag               
wing.K = wing.K+wing.Airfoil.K;                                             % Lift Dependent Drag
%[text] Introduce an aspect ratio constraint for validity of Prandtl lifting-line theory. Put upper bound on aspect ratio for structural strength.
designprob.Constraints.WingAR = wing.AspectRatio>=6;
designprob.Constraints.HTailAR = wing.AspectRatio<=12;
%[text] ## Aerodynamic Effect of Wing on Horizontal Tail
%[text] Add the effect of downwash from the wing to the horizontal tail, which reduces its efficiency.
hTail.Efficiency = 1;                                                       % Horizontal Tail Dynamic Pressure Ratio
hTail.Downwash = 2/(2+wing.AspectRatio);                                    % Horizontal Tail Downwash gradient
%[text] ## Horizontal Tail Aerodynamics
%[text] Use Prandtl lifing-line theory to estimate the horizontal tail's lift and drag coefficients. 
numcoeff = 10;
B = fcn2optimexpr(@PrandtlCoefficients,hTail.HalfSpan,...
    hTail.Chord,1,hTail.Airfoil, numcoeff,...
    'OutputSize',[numcoeff,1],'ReuseEvaluation',true);                      % Prandtl lifting-line Coefficients
hTail.ClAlpha = B(1)*pi*hTail.AspectRatio;                                  % Lift Slope
hTail.Cd0 = hTail.Airfoil.Cd0;                                              % Parastic Drag
%[text] Introduce an aspect ratio constraint for validity of Prandtl lifting-line theory. Put upper bound on aspect ratio for structural strength.
designprob.Constraints.HTailAR = hTail.AspectRatio>=4;
designprob.Constraints.HTailAR = hTail.AspectRatio<=8;
%[text] ## Vertical Tail Aerodynamics
%[text] Use Prandtl lifing-line theory to estimate the vertical tail's lift and drag coefficients. 
numcoeff = 10;
B = fcn2optimexpr(@PrandtlCoefficients,vTail.HalfSpan/2,...
    vTail.Chord,1,vTail.Airfoil, numcoeff,...
    'OutputSize',[numcoeff,1],'ReuseEvaluation',true);                      % Prandtl lifting-line Coefficients
vTail.CFBeta = B(1)*pi*vTail.AspectRatio;                                   % Side Force Slope
vTail.Cd0 = vTail.Airfoil.Cd0;                                              % Parastic Drag
%[text] Unlike for the wing, the vertical tail often has a lower aspect ratio, resulting in the underestimation of the tail's lift induced drag. Put upper bound on aspect ratio for structural strength.
designprob.Constraints.VTailAR = vTail.AspectRatio>=3;
designprob.Constraints.HTailAR = vTail.AspectRatio<=6;
%[text] ## Fuselage Aerodynamics
%[text] Estimate the fuselage drag by approximating it to be equal to the skin friction drag. Ignore interference and other harder to model phenomena. The turbulent flat-plate skin friction drag coefficient is based on numerical data for existing subsonic aircraft.
Cf = 0.455*(log(10)/log(aircraft.RePerLength*fuselage.Length))^2.58;        % Skin Friction Coefficient
FF = (1+60/fuselage.Fineness^3 + fuselage.Fineness/400);                    % Form Factor
fuselage.Cd = Cf*FF*fuselage.WettedArea/aircraft.ReferenceArea;             % Skin Friction Drag
%[text] ## Whole Aircraft Aerodynamics
aircraft.Cd0 = wing.Cd0 + fuselage.Cd...
    +hTail.Cd0*hTail.Efficiency*(hTail.PlanformArea/aircraft.ReferenceArea)...
    +vTail.Cd0*(vTail.PlanformArea/aircraft.ReferenceArea);                 % Parastic Drag
aircraft.K = wing.K;                                                        % Lift Dependent Drag
aircraft.ClAlpha = wing.ClAlpha;                                            % Lift Slope
aircraft.ClMax = aircraft.ClAlpha*aircraft.StallAoA;                        % Max Lift
end
%[text] *Copyright 2022 The MathWorks, Inc.*

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
