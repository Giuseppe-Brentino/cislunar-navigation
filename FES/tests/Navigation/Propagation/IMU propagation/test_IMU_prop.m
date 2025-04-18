classdef test_IMU_prop < matlab.unittest.TestCase

    properties
        data
    end

    methods(TestMethodSetup)

        function run_sim(testCase)
            % Run the simulink model
            testCase.data = sim("IMU_int.slx");
        end

    end

    methods(Test)
        % Test methods

        function test_gyro_integration(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test integration accuracy of different gyroscope integration
            % methods.
            % Compares the integration error of Forward Euler, Trapezoidal,
            % and coning correction methods with respect to ground truth
            % angles.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Extract data
            time = testCase.data.real_angles.Time;
            real_angles = testCase.data.real_angles.Data;
            FE_angles = testCase.data.fe_angles.Data;
            trapz_angles = testCase.data.trapz_angles.Data;
            coning_angles = testCase.data.coning_angles.Data;

            % Compute angular errors
            FE_error = angdiff(real_angles,FE_angles);
            trapz_error = angdiff(real_angles,trapz_angles);
            coning_error = angdiff(real_angles,coning_angles);

            % Compute integrated error (absolute error over time)
            FE_errInt = trapz(time,abs(FE_error));
            trapz_errInt = trapz(time,abs(trapz_error));
            coning_errInt = trapz(time,abs(coning_error));

            % Verify that coning correction yields smallest error
            testCase.verifyGreaterThan(FE_errInt,coning_errInt)
            testCase.verifyGreaterThan(trapz_errInt,coning_errInt)
        
        end
        
    end

end