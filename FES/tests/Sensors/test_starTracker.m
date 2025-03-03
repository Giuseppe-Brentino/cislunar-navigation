classdef test_starTracker < matlab.unittest.TestCase


    methods(Test)

        function test_visibleStars(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Visible Stars Detection
            % This function verifies that the star tracker correctly
            % identifies the visible stars within its field of view (FoV)
            % based on the given star catalogue and orientation.
            %
            % The test sets up a star catalogue with predefined star
            % positions and verifies if the simulation correctly determines
            % the visible stars.
            % It tests that a star that is not visible is not added to the
            % list and a visible star is not added if the maximum amount of
            % stars was already identified.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Configure star tracker parameters
            starTracker.maxStars.value = 10;
            starTracker.fov.value = deg2rad(10);
            starTracker.catalogue.value = ones(12,3)/sqrt(3);

            % Define star positions by rotating around the Y-axis of an
            % angle that guarantees that the star is visible
            pos = zeros(9,3);
            angles = 1:0.5:5;
            for i = 1:length(angles)
                roty = [cosd(angles(i)) 0 sind(angles(i)); 0 1 0; ...
                    -sind(angles(i)) 0 cosd(angles(i))];
                pos(i,:) = (roty*[1;0;0])';
                starTracker.catalogue.value(i,:) = pos(i,:);
            end

            % Rotate an additional stars around the Z-axis. This star is
            % visible and is placed after a non visible star in the list
            rotz = [cosd(5) sind(5) 0; -sind(5) cosd(5) 0; 0 0 1];
            starTracker.catalogue.value(11,:) = (rotz*[1;0;0])';

            % Add a visible star at the end of the catalogue that shouldn't
            % be considered as visible
            starTracker.catalogue.value(12,:) = [1;0;0];

            % Set brightness values for all stars for compatibility with
            % real catalogue
            starTracker.catalogue.value(:,4) = ones(12,1);

            % Define camera pointing direction
            camera_direction = [1;0;0];

            % Run the simulation
            simulation = sim('Models\starTracker\visible_stars.slx','srcWorkspace','current');

            % Extract actual visible stars from simulation
            actual_visible_stars = simulation.visible_stars(:,:,1);

            % Define expected visible stars based on the configured catalogue
            expected_visible_stars = starTracker.catalogue.value([1:9,11],1:3);

            % Verify that the simulation correctly identifies visible stars
            testCase.verifyEqual(actual_visible_stars,expected_visible_stars);

        end

        function test_emptyRows(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Removal of Empty Rows
            % This function verifies that the Simulink block correctly
            % removes rows containing only zeros from an input matrix.
            %
            % The expected output is a matrix with non-zero rows retained.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define the initial input matrix with some zero rows
            initial_matrix = [0 0 0; 0 1 0; 1 1 0; 0 0 0; 1 1 1; 0 0 0];

            % Run the simulation
            model = sim("Models\starTracker\cut_matrix.slx",'srcWorkspace','current');

            % Define expected output matrix (zero rows removed)
            expected_out = [0 1 0; 1 1 0; 1 1 1];

            % Extract actual output from simulation
            actual_out = model.matrix.Data{1};

            % Verify that the output matches the expected matrix
            testCase.verifyEqual(actual_out,expected_out)
        
        end

    end

end