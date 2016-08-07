function [ Base_Zern,msk] = Base_Zernike( n_rad,D_pup,R )
%Base_Zernike fabrique tous les modes de Zernike jusqu'au dernier mode
%d'ordre radial n_rad, exepté le piston.
%   Entrées :
%   - n_rad : Ordre radial du dernier mode de Zernike considéré dans la
%   base.
%   - D_pup : diamètre de la pupille d'entrée du télescope (en m)
%   - R : resolution lineaire en pixel de la phase
%   Sortie :
%   - Base_Zern : matrice R*R*n_modes contenant tous les modes de Zernike
%   jusqu'au dernier d'ordre radial n_rad.

%RJ%05/03/2015%

% Calcul du nombres total de modes de Zernike à construire
n_modes = (n_rad)*(n_rad+3)/2;

% Création des matrice de coordonnées dans la pupille
x = linspace(-D_pup/2,D_pup/2,R);
[x_pup,y_pup]=meshgrid(x,x);
[ r,theta ] = Conv_Cart_to_Pol( x_pup,y_pup );

% Création du masque circulaire
[ msk ] = Mask_circ( R );


% Création des modes de la base de Zernike
Base_Zern = zeros(R,R,n_modes);

for i = 1:n_modes
    [n,m] = Zern_num(i+1);
    N_nm = sqrt(2*(n+1)/(1+Fonction_Kreonecker(m,0)));
    R_nm = 0;
    for s = 0:(n-abs(m))/2
        R_nm = R_nm + r.^(n-2*s)*(-1)^s*prod(1:(n-s))/(prod(1:s)*prod(1:(0.5*(n+abs(m))-s))*prod(1:(0.5*(n-abs(m))-s)));
    end
    if m==0
        Theta_nm = ones(R,R);
    elseif mod(i+1,2)==0;
        Theta_nm = cos(m*theta);
    elseif mod(i+1,2)==1;
        Theta_nm = sin(m*theta);
    end
    Base_Zern(:,:,i) = N_nm*R_nm.*Theta_nm.*msk;
end
end

