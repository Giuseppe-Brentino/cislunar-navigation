classdef visibleStars < matlab.System

    properties(Nontunable)
        starTracker
    end

    methods (Access = protected)

        function [s_if] = stepImpl(obj, A_BN)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute Visible Stars in Sensor's Field of View
            %
            % This function determines which stars from the catalogue are
            % visible within the sensor's field of view, given the current 
            % attitude.
            %
            % INPUT:
            %   obj   - the class itself, containing star tracker parameters
            %   A_BN  - Rotation matrix from inertial frame (N) to body 
            %           frame (B)
            %
            % OUTPUT:
            %   s_if  - Matrix containing the position vectors of visible
            %           stars in inertial frame
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Extract star tracker parameters
    n_max = obj.starTracker.maxStars.value;  % Maximum number of detectable stars
    catalogue = obj.starTracker.catalogue.value;  % Star catalogue with unit vectors
    fov = obj.starTracker.fov.value;  % Field of view (radians)
    A_SB = obj.starTracker.A_BS.value';  % Rotation matrix from body to sensor frame

% Initialize output matrix for visible stars
            s_if = zeros(n_max,3);
            i = 1; % Index for star catalogue
            j = 1; % Index for visible stars

            % Iterate through the star catalogue
            while j<n_max+1 && i<=size(catalogue,1)

                % Compute star's normalized position vector in the sensor frame
                S_temp = A_SB*A_BN*(catalogue(i,1:3))';

                % Compute the angle between the star's position and the sensor's boresight
                theta = acos( dot(S_temp,[0;0;1])/norm(S_temp) );
               
                % Check if the star is within the field of view
                if theta <= fov/2

                    % Store star position
                    s_if(j,:) = catalogue(i,1:3);
                    
                    % Move to next visible star
                    j = j + 1;
                end

                % Move to next star in the catalogue
                i= i+1;
            end

        end

    end

end


