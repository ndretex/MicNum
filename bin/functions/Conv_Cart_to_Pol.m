function [ r,theta ] = Conv_Cart_to_Pol( x,y )
%Conv_Cart_to_Pol Convertit des coordonnées carthésiennes en coordonnées
%polaires.
%   Entrées :
%   - x, y : coordonnées carthésiennes
%   Sorties :
%   - r,theta : coordonnées polaires

%RJ%05/03/2015%

r = sqrt(x.^2+y.^2);
if r
    theta = 2*atan(y./(x+r));
else % convention pour le cas r = 0 (evite les NaN)
    theta = 0; 
end
end

