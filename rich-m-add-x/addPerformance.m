%[text] Add takeoff distance constraint to optimization problem.
function [aircraft,designprob] = addPerformance(aircraft, S, cbar, designprob)

gravity = 9.81;                                                                    % Acceleration of gravity [m/s^2]
airDensity = 1.225;                                                                % Air Density [kg/m^3]
%[text] ## Static Margin
%[text] The static margin is already guaranteed to be positive by the stability constraint $C\_{m\_{\\alpha}} \<= 0$. However, a high static margin can lead to the aircraft requiring large elevator deflection to pitch up or down, whereas low static margin can make the aircraft too sensitive to elevator deflections. Therefore, impose maximum and minimum values on the static margin.
aircraft.StaticMargin = (aircraft.NeutralPoint - aircraft.Xcg)/cbar;
designprob.Constraints.StaticMarginU = aircraft.StaticMargin<=0.25;
designprob.Constraints.StaticMarginL = aircraft.StaticMargin>=0.05;
%[text] ## Ground Roll Distance
%[text] The competition rules restrict the takeoff distance to 100 ft.
aircraft.WingLoading = aircraft.Mass*gravity/aircraft.ReferenceArea;              % Wing Loading [N/m^2]
aircraft.StallSpeed = sqrt(2*aircraft.WingLoading/(airDensity*aircraft.ClMax));   % Stall Speed [m/s]
aircraft.TakeOffSpeed = 1.15*aircraft.StallSpeed;                                 % Take off speed [m/s]
aircraft.ClTO = aircraft.Mass*gravity/...
     (1/2*airDensity*aircraft.TakeOffSpeed^2*S);
KT = aircraft.MaxThrust/(aircraft.Mass*gravity)-aircraft.RollingResistance;
KA = (airDensity/(2*aircraft.WingLoading))*...
     (aircraft.RollingResistance*aircraft.ClTO-aircraft.Cd0-aircraft.K...
     *aircraft.ClTO^2);
aircraft.GroundRoll = log(1+KA/KT*aircraft.TakeOffSpeed^2)/(2*gravity*KA);        % Ground Roll before take off [m]

designprob.Constraints.GroundRoll = aircraft.GroundRoll<=30.48;
end
%[text] *Copyright 2022 The MathWorks, Inc.*

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
