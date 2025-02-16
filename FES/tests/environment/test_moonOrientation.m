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
            testCase.startDate = datetime(y,m,d,h,min,s);
            epoch = testCase.startDate + seconds(testCase.simulation.tout);
            testCase.epochs =  cspice_str2et( char(epoch) );

        end
    end

    methods(Test)
        % Test methods
        function test_JD(testCase)
            expected = juliandate(testCase.startDate+seconds(testCase.simulation.tout));
            actual = testCase.simulation.jd.Data;
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end

        function test_J2000ToMPA(testCase)
            % Compute transformation matrix using spice
            real_mat = cspice_sxform( 'J2000', 'MOON_PA', testCase.epochs);
            sim_mat = testCase.simulation.sim.J2000ToMPA.Data;
            verifyEqual(testCase,sim_mat,real_mat,'RelTol',testCase.tol)
        end

    end

end