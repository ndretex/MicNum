function [ Mask ] = Circ_mask( N_pix_lin,Diam_pix_lin )
%Circ_mask.m Crée un masque circulaire (1 a l'interieur, 0 a l'exterieur)
%de diametre Diam_pix_lin pixel dans une matrice de resolution N_pix_lin x 
%N_pix_lin.
%   Entrées:
%   - N_pix_lin : resolution lineaire en pixel du mask (matrice)
%   - Diam_pix_lin : diametre en pixel du cercle
%   Sortie:
%   - Mask : masque circulaire
%RJ%18/03/2016%

% rapport entre la taille du mask et le diamètre du cercle
ratio = N_pix_lin/Diam_pix_lin;
% coordonnées dans la matrices
[X,Y] = meshgrid(linspace(-ratio,ratio,N_pix_lin));
rho = sqrt(X.^2+Y.^2);
% création du masque
Mask = zeros(N_pix_lin);
Mask(rho<=1) = 1;

end

