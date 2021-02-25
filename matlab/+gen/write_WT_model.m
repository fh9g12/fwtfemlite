function write_WT_model(fold_angle,flare_angle,origin,root_aoa,varargin)
%WRITE_WT_MODEL Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    p.addOptional('GravStiffness',false,@is_logical_1_0);
    p.parse(varargin{:});
    
    hinge_file = 'C:\Git\fwtfemlite\hinge.bdf';
    coords_file = 'C:\Git\fwtfemlite\fwt_coord.bdf';

    %% create coords file
    fid = fopen(coords_file,'w+');
    coords = gen.fwt_coords(fold_angle,flare_angle,origin,root_aoa);
    coords.writeToFile(fid)
    fclose(fid);
    
    %% create hinge file
    if p.Results.GravStiffness
        K = 0.904*sind(-fold_angle);
    else
        K = 0;
    end
    % ensure stiffness is not completely zero
    if abs(K)<1e-4
        K=1e-4;
    end    
    gen.write_hinge(hinge_file,K)
end

function res = is_logical_1_0(x)
    if islogical(x)
        res = true;
    elseif isnumeric(x) && (x==1 || x==0)
        res = true;
    else
        res = false;
    end
end

