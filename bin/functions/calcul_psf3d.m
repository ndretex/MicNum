function psf3d=calcul_psf3d(aberr,sigmagauss,pupwidth,a4_tab)
    
    imwidth=pupwidth*2;
    
    % modes zernikes; a faire
    
    na4=length(a4_tab);
    psf3d=double(zeros(imwidth,imwidth,na4));
    [modes_zern,mask]=Base_Zernike(4,2,pupwidth);
    
    if sigmagauss ~= 0
        faisceaugauss=faisceaugaussien(sigmagauss*pupwidth/2,1,pupwidth/2);
    else
        faisceaugauss=mask;
    end
    
defoc=modes_zern(:,:,3);
 
    for a4_iter = 1:na4
        cur_psf=calc_psf_phase_gauss((a4_tab(a4_iter).*defoc)+aberr,...
            faisceaugauss,mask,imwidth,pupwidth);
        psf3d(:,:,a4_iter)=cur_psf;
    end
end
    