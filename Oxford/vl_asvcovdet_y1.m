% ASV Demo Code 
% Version: 1 (2016/3/11)
% 
% 
% All rights reserved.
% -----------------------------------------------------------------------------------------------
% Code author: Tsun-Yi Yang 
% Email: shamangary@hotmail.com
% Project page: http://shamangary.logdown.com/posts/587520
% Paper: [CVPR16] Accumulated Stability Voting: A Robust Descriptor from Descriptors of Multiple Scales
% 
% If you use the code, please cite the paper.
% If any bug is found, please email me.
% You may use the code for academic study.
% However, using the provided code for commercial purpose is forbidden.
% -----------------------------------------------------------------------------------------------
% Tested platform:
% Ubuntu 12.04 LTS (I do not test the code on Windows or Mac.)
% Matlab R2012b
% 
% -----------------------------------------------------------------------------------------------

function [D_out] = vl_asvcovdet_y1(im, opt, frames_ori,des,isInter)

nr = opt.nr;
rc_min = opt.rc_min;
rc_max = opt.rc_max;
% ostateczny wynik to D_out
D_out = [];
frames = frames_ori;
nf = size(frames_ori, 2);
% dla r�?nych rozmiar�w skali????
for rc = linspace(rc_min, rc_max, nr)
    
    frames([1 2], :) = frames_ori([1 2], :);
    for rf = 1:nf
        frames(3:6, rf) = reshape([cos(rc) -sin(rc);sin(rc) cos(rc)] * reshape(frames_ori(3:6,rf),2,2),4,1);
    end
    
    
    
    
    ns = opt.ns;
    sc_min = opt.sc_min;
    sc_max = opt.sc_max;
    % Sample scales around detection
    
    f = zeros(6, nf, ns);
    cnt = 0;
    for sc = linspace(sc_min, sc_max, ns)
        cnt = cnt + 1;
        f([1 2], :, cnt) = frames([1 2], :);
        f(3:6, :, cnt) = sc * frames(3:6,:);
    end
    
    
    
    if strcmp(des,'sift') == 1
        dim = 128;
    elseif strcmp(des,'liop') == 1
        dim = 144;
    elseif strcmp(des,'patch') == 1
        dim = 1681;
    end
    D = zeros(dim,nf,ns);
    for i = 1:ns
        [~,d] = extract(im,des,f(:,:,i));
        D(:,:,i) = d;
    end
    
    D = permute(D,[1,3,2]);
    
    % ------------------------------interpolation -----------------------------------
    if isInter == 1
        for in = 1:size(D,2)-1
            tempIntep = (D(:,in,:) + D(:,in+1,:))/2;
            D = cat(2,D,tempIntep);
        end
    end
    % ------------------------------interpolation -----------------------------------
    
    % spr�bujmy policzy? threshold globalny
    threshold_candidates = [];
    for i_f = 1:nf
        m_candidates = []; % kandydaci dla danego i_f
        for c = 1:size(D,2)-1
            
            temp = D(:,c,i_f);
            % r�?nica frame'�w
            M = bsxfun(@minus,D(:,(c+1):end,i_f),temp);
            M = abs(M);
            %% 1st stage median thresholding
            m_candidate = median(M,1);
            m_candidate = median(m_candidate);
            m_candidates = [m_candidates;m_candidate]; %(do listy)
            
        end
        
        threshold_candidates = [threshold_candidates;m_candidates];
    end
    threshold_global = median(threshold_candidates); % or mean, etc.

    % dla ka?dej skali liczymy d_out
    d_out = [];
    for i_f = 1:nf
        % dla ka?dego frame'a liczymy accVec
        accVec = zeros(dim,1);
        
        for c = 1:size(D,2)-1
            
            temp = D(:,c,i_f);
            % r�?nica frame'�w
            M = bsxfun(@minus,D(:,(c+1):end,i_f),temp);
            M = abs(M);
            %% 1st stage median thresholding
          
            for t = 1:size(M,2)
                
                accVec = accVec + (M(:,t) <= threshold_global);
                
            end
            
        end
        
        accVec = double(accVec);
        d_out = [d_out,accVec];
    end
    
    D_out = [D_out;d_out];
end




end