classdef visibleStars < matlab.System
    properties(Nontunable)
       starTracker
    end

    methods (Access = protected)

        function [s_if] = stepImpl(obj,A_BN)

            n_max = obj.starTracker.maxStars.value;
            catalogue = obj.starTracker.catalogue.value;
            fov = obj.starTracker.fov.value;
            A_SB = obj.starTracker.A_BS.value';

            s_if = zeros(n_max,3);
            i = 1;
            j = 1;

            while j<n_max+1 && i<size(catalogue,1)

                % star's normalized position vector in sensor frame
                S_temp = A_SB*A_BN*(catalogue(i,1:3))';

                % angle between star's position vector and sensor's pointing axis
                theta = acos( dot(S_temp,[0;0;1])/norm(S_temp) );
                % check if star is in field of view
                if theta <= fov/2
                    s_if(j,:) = catalogue(i,1:3);
                    j = j + 1;
                end
                i= i+1;
            end

        end

    end

end


