function [ n,m ] = Zern_num( num )
%Zern_num Transcription de la fonction IDL qui calcule l'ordre radial et
%l'ordre azimutal d'un mode de zernike à partir de son indice.
%   Entrées :
%   - num : indice du mode de Zernike (mono)
%   Sorties :
%   - n : ordre radial
%   - m : ordre azimutal
%
%   Si num est un vecteur, n et m sont des vecteurs.
%   Fonction IDL rédigée par Laurent MUGNIER (dernière révision : 2001)

%RJ%05/03/2015%

% Calcul de l'ordre radial
n = floor(floor((sqrt(8*num-7)-1))/2);

%Calcul de l'ordre azimutal
m = zeros(size(n));

tab_pair = find(mod(n,2)==0);
tab_impair = find(mod(n,2)==1);

if isempty(tab_impair)==0
    m(tab_impair) = 1+2*floor((num(tab_impair)-1-floor(n(tab_impair).*(n(tab_impair)+1))/2)/2);
end
if isempty(tab_pair)==0
    m(tab_pair) = 2*floor((num(tab_pair)-floor((n(tab_pair).*(n(tab_pair)+1))/2))/2);
end

% num = num-1;
% 
% m = abs(2*num-n.*(n+2));

end

