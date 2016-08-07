function psf=calc_psf_phase_gauss(phase,faisceugauss,mask,imwidth,pupwidth)
    
    if nargin ==4
        pupwidth=size(mask,1);
        amplpup_pupwidth = exp(1i.*phase).*mask.*faisceugauss;
    else
        amplpup_init=exp(1i.*phase).*mask.*faisceugauss;
        amplpup_pupwidth=amplpup_init(...
            (size(amplpup_init,1)-pupwidth)/2+1:(size(amplpup_init,1)+pupwidth)/2,...
            (size(amplpup_init,1)-pupwidth)/2+1:(size(amplpup_init,1)+pupwidth)/2);
    end
    
    amplpup=double(zeros(imwidth,imwidth));
    amplpup(1:size(amplpup_pupwidth,1),1:size(amplpup_pupwidth,1))=amplpup_pupwidth;
    amplfoc = fftshift(ifft2(amplpup));
    psf=abs(amplfoc).^2;
    psf=psf./sum(psf(:));
end