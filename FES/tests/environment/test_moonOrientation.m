classdef test_moonOrientation < matlab.unittest.TestCase

    properties
        simulation
        startDate
        epochs
        tol = 1e-6
    end

    methods (TestMethodSetup)

        function setup(testCase)

            % Load spice data
            cspice_furnsh(strcat('../../Data/moon_pa_de421_1900-2050.bpc'));
            cspice_furnsh(strcat('../../Data/moon_080317.tf'));
            cspice_furnsh(strcat('../../Data/naif0012.tls'));

            % Run test model
            testCase.simulation = sim('./Models/moonOrientation_test.slx');

            % Get julian date of the simulation steps
            Env = getParameters('Scenario.sldd',{'Environment'});

            % Get integration timesteps
            date = Env{1}.Date;
            y = date.year;
            m = date.month;
            d = date.day;
            h = date.hour;
            min = date.min;
            s = date.sec;

            % Create the start date as a datetime object
            testCase.startDate = datetime(y,m,d,h,min,s);

            % Calculate the epochs by adding the simulation time steps to the start date
            epoch = testCase.startDate + seconds(testCase.simulation.tout);

            % Convert to ephemeris time (ET) using CSPICE
            testCase.epochs =  cspice_str2et( char(epoch) );

        end
    end

    methods(Test)
        % Test methods

        function test_JD(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Julian Date Calculation
            % This function verifies that the calculated Julian date from
            % the simulation matches the expected Julian date based on the
            % start date and simulation time steps.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Calculate the expected Julian date based on the start date and simulation
            expected = juliandate(testCase.startDate+seconds(testCase.simulation.tout));

            % Extract the actual Julian date from the simulation data
            actual = testCase.simulation.jd.Data;

            % Verify that the actual Julian date matches the expected value
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end

        function test_J2000ToMPA(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test J2000 to MPA Transformation Matrix
            % This function verifies that the J2000 to MPA transformation 
            % matrix matches the expected
            % transformation matrix computed with SPICE.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Compute the expected transformation matrix using SPICE
            real_mat = cspice_sxform( 'J2000', 'MOON_PA', testCase.epochs);

            % Extract the actual transformation matrix from the simulation data
            sim_mat = testCase.simulation.sim.J2000ToMPA.Data;

            % Verify that the simulated transformation matrix matches the expected matrix
            verifyEqual(testCase,sim_mat,real_mat,'RelTol',testCase.tol)
        end

    end

end