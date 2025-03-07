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

        function test_sensorUsability(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Sensor Usability
            % This function verifies the usability of the star tracker
            % based on the boresight direction and the positions of
            % celestial bodies (moon, earth, sun).
            % It checks that the sensor correctly identifies when each body
            % is in its field-of-view or within an exclusion zone.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Import constraints for the verification
            import matlab.unittest.constraints.IsFalse
            import matlab.unittest.constraints.IsTrue

            % environment and sensor parameters
            R_M = 1000; % moon radius
            R_E = 1000; % earth radius
            fov = deg2rad(10); % sensor's field of view
            exclusionAngle = deg2rad(35); % sun exclusion angle

            % Celestial bodies position
            moon = timeseries(zeros(3,12),0:11);
            earth = timeseries(100*ones(3,12),0:11);
            sun = timeseries(100*ones(3,12),0:11);

            %%% Satellite position

            % Test moon check
            sat_pos = [1100, 30000 ;
                0, 0;
                0, 0];
            sat_pos = repmat(sat_pos,1,2);

            % Add data for earth check
            sat_pos = [sat_pos, sat_pos + 100*ones(3,4)];

            % Add data for sun check
            sat_pos = [sat_pos,zeros(3,4)];
            sat = timeseries(sat_pos,0:11);

            %%% Boresight direction

            % Pointing towards the body moon and away from it for each
            % distance
            dir_data = [-1 -1 1 1; 0 0 0 0; 0 0 0 0];

            % Repeat for the earth case
            dir_data = repmat(dir_data,1,2);

            % Rotate to test planet outside fov
            rot_dir = [cosd(85) 0 -sind(85); 0 1 0; sind(85) 0 cosd(85)]*[-1;0;0];
            dir_data(:,[2,6]) = repmat(rot_dir,1,2);

            % Add rotation to the sun direction to test exclusion angle
            sun_dir = 1/sqrt(3)*ones(3,1);
            rotm1 =[cosd(30) 0 -sind(30); 0 1 0; sind(30) 0 cosd(30)];
            rotm2 =[cosd(50) 0 -sind(50); 0 1 0; sind(50) 0 cosd(50)];
            dir_data = [dir_data, rotm1*sun_dir, rotm2*sun_dir,...
                -rotm1*sun_dir, -rotm2*sun_dir];
            dir = timeseries(dir_data,0:11);

            % Run the model
            simulation = sim("Models\starTracker\usability.slx",'srcWorkspace','current');

            % Verify moon in fov
            testCase.verifyThat(simulation.moon_check.Data(1),IsFalse)
            testCase.verifyThat(all(simulation.moon_check.Data(2:4)),IsTrue)

            % Verify earth in fov
            testCase.verifyThat(simulation.earth_check.Data(5),IsFalse)
            testCase.verifyThat(all(simulation.earth_check.Data(6:8)),IsTrue)

            % Verify sun in exclusion angle
            testCase.verifyThat(simulation.sun_check.Data(9),IsFalse)
            testCase.verifyThat(all(simulation.sun_check.Data(10:12)),IsTrue)

            % Verify total usability
            exp_usability = simulation.sun_check.Data & simulation.earth_check.Data...
                & simulation.moon_check.Data;
            testCase.verifyEqual(simulation.usability.Data,exp_usability);
        end

        function test_starsSensorFrame(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Star coordinates in sensor frma
            % This function verifies whether the coordinates of the stars 
            % centroids in the focal plane are simulated correctly.
            % Then it verifies that the derived coordinates in sensor frame
            % are simulated correctly.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Retrieve star tracker parameters from data dictionary
            data = getParameters('Sensors.sldd',{'starTracker'});
            starTracker = data{1};
            starTracker.noise.value = 0; % Disable noise for deterministic results
            
            % Define star positions in inertial frame
            rotm = [1 0 0; 0 cosd(3) -sind(3); 0 sind(3) cosd(3)];
            stars = [0 0 1; (rotm*[0;0;1])'];
            
            % Run the model
            simulation = sim('Models/starTracker/rotated_stars.slx','srcWorkspace','current');

            % Extract actual centroid coordinates from the model output
            actual_centroids = simulation.centroids(1:2,:,1);
            
            % Extract actual star coordinates from the model output
            actual_coord = simulation.stars_sf(1:2,:,1);

            % Compute expected centroid coordinates based on star positions
            exp_centroids = zeros(2,2);
            exp_centroids(2,:) = starTracker.f.value*[stars(2,1:2)]/stars(2,3);

            % Verify the computed centroids match expected values within tolerance
            testCase.verifyEqual(actual_centroids,exp_centroids,'relTol',1e-10);

            % Verify that the computed coordinates match the expected one.
            % Since no rotation between frame is considered, the
            % coordinates in sensor and inertial frame should be equal
            testCase.verifyEqual(actual_coord,stars,'relTol',1e-10);
        end

    end

end