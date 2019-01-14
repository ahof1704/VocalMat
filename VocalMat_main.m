disp('Starting VocalMat')

path_identifier = 'C:\Users\ahf38\Documents\GitHub\VocalMat\VocalMat - Identifier';
path_classifier = 'C:\Users\ahf38\Documents\GitHub\VocalMat\VocalMat - Classifier';

disp(['[vocalmat]: Starting the Identifier...'])
cd(path_identifier); run('VocalMat_Identifier.m')

disp(['[vocalmat]: Starting the classifier...'])
cd(path_classifier); run('VocalMat_Classifier.m')

