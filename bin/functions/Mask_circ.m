function [ msk ] = Mask_circ( R )
%Mask_circ fabrique un masque circulaire
%   Entrée :
%   - Résolution de la matrice
%   Sortie :
%   - msk : masque circulaire : matrice carrée (RxR) contenant un disque de
%   1 et que des 0 autour.

%RJ%06/03/2015%

t = linspace(-1,1,R);
[x,y] = meshgrid(t,t);
msk = double((x.^2+y.^2)<=1);

end

