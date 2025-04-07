%[text] Model and add weight, center of gravity, and sizing constraints.
function [aircraft, wing, fuselage, hTail, vTail, payload, designprob] = ...
    addWeightAndSizing(aircraft, wing, fuselage, hTail, vTail, payload, designprob)
%[text] ## Aircraft Sizing Constraints
%[text] Payload sizing constraint (fuselage must be big enough to hold payload bay).
payload.Length = payload.Spherical.Diameter...
    + payload.Boxed.Length;
designprob.Constraints.PayloadGeometry = ...
 (payload.XLoc+payload.Length)<=fuselage.Length;
%[text] Wing tip chord constraint (must be minimum 15 cm).
wing.TipChord = wing.TaperRatio*wing.RootChord;
designprob.Constraints.WingTipChord = wing.TipChord>=0.15;
%[text] Wing location constraint (wing must be in the 1st half of the fuselage).
designprob.Constraints.WingLoc = ...
    wing.Xac<=0.5*fuselage.Length;
%[text] ## Aircraft Mass Calculation (Component buildup method)
fuselage.Mass = fuselage.Density*0.75*fuselage.WettedArea;               % Fuselage Contribution
wing.Mass = wing.Density*wing.PlanformArea;                              % Wing Contribution
hTail.Mass = hTail.Density*hTail.PlanformArea;                           % Horizontal Tail Contribution
vTail.Mass = vTail.Density*vTail.PlanformArea;                           % Vertical Tail Contribution
payload.Boxed.Mass = payload.Boxed.Density...
    *payload.Boxed.Length*payload.Boxed.Height*fuselage.SideLength;      % Boxed Payload Mass
payload.Mass=payload.Boxed.Mass+payload.Spherical.Mass;                  % Total Payload Mass
aircraft.Mass= fuselage.Mass + wing.Mass...
                  + hTail.Mass + vTail.Mass...
                  + aircraft.Avionics.Mass + payload.Mass;               % Gross Aircraft Mass
%[text] SAE constraint on aircraft mass (mass should not exceed 24.9 kg).
designprob.Constraints.GrossWeight=aircraft.Mass<=24.9;
%[text] ## Aircraft C.G. Calculation (Component buildup method)
wing.Xcg = wing.XLoc+0.3*wing.RootChord;                                 % Wing C.G. assumed at 0.3 Chord
payload.Xcg = payload.XLoc + (payload.Length)/2;                         % Payload C.G. Calculation
hTail.Xcg = fuselage.Length-0.6*hTail.Chord;                             % Horizontal Tail C.G. assumed at 0.4 Chord
vTail.Xcg = fuselage.Length-0.6*vTail.Chord;                             % Vertical Tail C.G. assumed at 0.4 Chord
aircraft.Xcg = (fuselage.Mass*fuselage.Xcg ...
   + wing.Mass*wing.Xcg ...
   + hTail.Mass*hTail.Xcg ...
   + vTail.Mass*vTail.Xcg ...
   + aircraft.Avionics.Xcg*aircraft.Avionics.Mass ...
   + payload.Xcg*payload.Mass)/aircraft.Mass;                            % Weighted Average to calculate aircraft C.G.


%[text] Constrain vertical and horizontal tail positions so that they do not interfere with the wing (at least 10 cm gap).
designprob.Constraints.HTailLoc = fuselage.Length - hTail.Chord -...
                                 (wing.XLoc + wing.RootChord) >= 0.1;
designprob.Constraints.VTailLoc = fuselage.Length - vTail.Chord -...
                                 (wing.XLoc + wing.RootChord) >= 0.1;
end
%[text] *Copyright 2022 The MathWorks, Inc.*

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":40}
%---
