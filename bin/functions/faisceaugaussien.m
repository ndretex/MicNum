% PRO FAISCEAUGAUSSIEN, WAIST_EMISS = waist_emiss, AMPLI_EMISS = ampli_emiss, RHO = rho, FAISCEAUGAUSS = faisceaugauss, RAYON_TRONCATURE = rayon_troncature
% 
% ;faisceau dans le plan d'emission
% 
% ;waist_emiss en nbre de pixels
% ;rayon_troncature = rayon_pleine_pupille peut être plus grand, egal ou plus petit que waist_emiss 
% 
% rho = distc(2*round(rayon_troncature), 2*round(rayon_troncature), cx = round(rayon_troncature), cy = round(rayon_troncature))
% ;rho = distc(2*rayon_troncature, 2*rayon_troncature, cx = rayon_troncature, cy = rayon_troncature)
% 
% faisceaugauss = ampli_emiss*exp(-rho^2/waist_emiss^2)
% 
% END

function result=faisceaugaussien(waist,ampli,rayon_tr)
    largeur=2*rayon_tr;
    centre_x=(largeur-1)/2;
    centre_y=centre_x;
    x=0:largeur-1;
    [x,y]=meshgrid(x);
    x=x-centre_x;
    y=y-centre_y;
    
    rho=double(sqrt(x.^2+y.^2));
    
    result = ampli.*exp(-rho.^2/waist.^2);
    
    
end