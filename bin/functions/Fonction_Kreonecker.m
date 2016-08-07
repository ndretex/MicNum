function [ delta ] = Fonction_Kreonecker( i,j )
%Fonction_Kreonecker est la fonction de kroenecker. La sortie est 1 si i =
%j, et 0 sinon.
%   Entrées :
%   - i,j : nombres d'entrée
%   Sortie :
%   - delta : résultat de la fonction de K.

%RJ%02/03/2015%

if i == j
    delta = 1;
else
    delta = 0;
end

end

