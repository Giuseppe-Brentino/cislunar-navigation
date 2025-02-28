classdef test_shadow < matlab.unittest.TestCase

    properties
        AU = 149597870.7; %km
        % from Montenbruck et al., Satellite Orbits
        f1 = deg2rad(0.269); % penumbra half angle
        f2 = deg2rad(0.264); % umbra half angle
        V2 = 1.384*1e6;      % distance at which the apparent radius of sun and earth is the same
        shadow_factors;
        rsat;
        Environment;
    end
    methods(TestClassSetup)
        % Shared setup for the entire test class

        function set_data(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Set Data for Shadow Factor Simulation
            % This function initializes environmental parameters and
            % satellite positions for the shadow factor simulation.
            % It then runs the simulation to get the expected shadow factor
            % values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % get class properties
            AU = testCase.AU;
            F2 = testCase.f2;

            % Retrieve environmental parameters from the scenario data dictionary
            env = getParameters('Scenario.sldd',{'Environment'});
            testCase.Environment = env{1};

            % Extract relevant environmental value
            earth_radius = testCase.Environment.Earth.radius.value;
            sun_radius = testCase.Environment.Sun.radius.value;
            V1 = -testCase.Environment.Earth.radius.value/sin(testCase.f1);

            % Define satellite positions in x, y, and z coordinates
            sat_pos_x = [ones(1,5)*testCase.V2/2, -ones(1,5)*testCase.V2/2];
            sat_pos_z = zeros(1,10);
            sat_V1_x = -V1 + sat_pos_x(1);
            sat_pos_y1 = [sat_V1_x*tan(F2)+1000, sat_V1_x*tan(F2)/2, 0, ...
                - sat_V1_x*tan(F2)/2, -sat_V1_x*tan(F2)-1000];
            sat_pos_y = [sat_pos_y1, sat_pos_y1];

            % Store computed satellite positions
            sat_pos_value = [sat_pos_x; sat_pos_y; sat_pos_z];
            testCase.rsat = sat_pos_value;

            % Define time vector for satellite positions
            sat_pos_time = linspace(0,9,10);

            % Create a timeseries object for the simulation
            sat_pos = timeseries(sat_pos_value,sat_pos_time);

            % Run the simulation
            simulation = sim("Models\shadow_test.slx",'SrcWorkspace','Current');

            % Store the computed shadow factors
            testCase.shadow_factors = simulation.simout;

        end

    end

    methods(Test)
        % Test methods

        function test_umbra(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Umbra Condition
            % This function verifies that the shadow factor is zero when
            % the satellite is in the Earth's umbra (full shadow).
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Verify that the shadow factor at index 3 is zero (umbra condition)
            testCase.verifyEqual(testCase.shadow_factors(3),0);
        end

        function test_noShadow(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test No Shadow Condition
            % This function verifies that the shadow factor is 1 when the
            % satellite is not in fully illuminated by the Sun.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Indices corresponding to no shadow (full sunlight)
            noShadow_array = [1,5,6:10];

            % Verify that the shadow factor is 1 for these indices
            testCase.verifyEqual(testCase.shadow_factors(noShadow_array),ones(7,1));
        end

        function test_penumbra(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Penumbra Condition
            % This function verifies that the shadow factor is computed
            % correctly when the satellite is in the Earth's penumbra.
            % The shadow factor is calculated the same way as the simulink
            % model, based on Montenbruck et al., Satellite Orbits.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Indices corresponding to the penumbra condition
            shadow_array = [2,4];

            % Retrieve environmental and satellite parameters
            rb = testCase.Environment.Earth.radius.value;
            rs = testCase.Environment.Sun.radius.value;
            rSat = testCase.rsat;

            for i = shadow_array

                % Compute apparent radii
                a = asin(rs/norm([-testCase.AU,0,0]' - rSat(:,i)));
                b = asin(rb/norm(-rSat(:,i)));
                c = acos( (-rSat(:,i)'*([-testCase.AU,0,0]'-rSat(:,i)) ) /...
                    (norm(rSat(:,i))*norm([-testCase.AU,0,0]' - rSat(:,i)) ) );

                % Compute penumbra shadow factor using Montenbruck's formula
                x = (c^2+a^2-b^2)/(2*c);
                y = sqrt(a^2-x^2);
                A = a^2*acos(x/a)+b^2*acos((c-x)/b) -c*y;
                actual_nu = 1-A/(pi*a^2);

                % Verify that the computed shadow factor matches the simulation output
                testCase.verifyEqual(testCase.shadow_factors(i),actual_nu);
            end
        end

    end

end