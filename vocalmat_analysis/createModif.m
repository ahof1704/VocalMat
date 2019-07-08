function [modif] = createModif(exp)

switch exp
    
    
    case{'1'}
        % EXP 1: two spirals, little scaling
        %
        disp('Exp1')
        % %chose your dataset
        modif.X1_3D = 0;
        modif.X2_3D = 0;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 0;
        modif.mirror = 0;
        modif.square = 0;
        modif.lines = 0;
        
        
    case{'2'}
        % EXP 2: two spirals, one mirrored
        %
        disp('Exp2')
        % %chose your dataset
        modif.X1_3D = 0;
        modif.X2_3D = 0;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 0;
        modif.mirror = 1;
        modif.square = 0;
        modif.lines = 0;
        
        
    case{'3b'}
        % EXP 3b: two spirals, X1 in 3D, X2 in 2D. Classes inverted in Domain 1
        %
        disp('Exp3b')
        % %chose your dataset
        modif.X1_3D = 1;
        modif.X2_3D = 0;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 1;
        modif.mirror = 0;
        modif.square = 0;
        modif.lines = 0;
        
    case{'3'}
        % EXP 3: two spirals, X1 in 3D, X2 in 2D
        %
        disp('Exp3')
        % %chose your dataset
        modif.X1_3D = 1;
        modif.X2_3D = 0;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 0;
        modif.mirror = 0;
        modif.square = 0;
        modif.lines = 0;
        
        
        
    case{'4'}
        % EXP 4: two spirals, X1 in 3D, X2 line in 3D
        %
        disp('Exp4')
        % %chose your dataset
        modif.X1_3D = 1;
        modif.X2_3D = 1;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 0;
        modif.mirror = 0;
        modif.square = 0;
        modif.lines = 1;
        
        
        
    case{'5b'}
        % EXP 5: two spirals, X1 = 3D, X2 = 3D
        %
        disp('Exp5b')
        % %chose your dataset
        modif.X1_3D = 1;
        modif.X2_3D = 1;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 1;
        modif.mirror = 1;
        modif.square = 0;
        modif.lines = 0;
        
        
    case{'5'}
        % EXP 5b: two spirals, X1 = 3D, X2 = 3D, classes inverted in Domain 1
        %
        disp('Exp5')
        % %chose your dataset
        modif.X1_3D = 1;
        modif.X2_3D = 1;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 1;
        modif.mirror = 0;
        modif.square = 0;
        modif.lines = 0;
        
        
    case{'6'}
        % EXP 6: two spirals, one mirrored, dimensions replicated
        %
        disp('Exp6')
        
        % %chose your dataset
        modif.X1_3D = 0;
        modif.X2_3D = 0;
        %
        modif.additDim = 1; % number of replication of the dimensions
        %
        % % chose your distortion!!
        modif.classes = 0;
        modif.mirror = 1;
        modif.square = 0;
        modif.lines = 0;
        
end

modif.additDimNoise = 0;