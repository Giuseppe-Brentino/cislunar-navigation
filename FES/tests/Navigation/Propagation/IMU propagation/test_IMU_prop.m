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
            % Test that the integration of the gyroscope gives acceptable
            % results
            actual_ori = squeeze(testCase.data.actual_ori);
            expected_ori = squeeze(testCase.data.expected_ori);
            orientation_error = angdiff(actual_ori,expected_ori);
            testCase.verifyEqual(orientation_error,orientation_error*0,'absTol',1e-8)
        end

        function test_acc_integration(testCase)
            % Test that the integration of the accelerometer gives acceptable
            % results
            v_error = squeeze(testCase.data.v_error) ;
            testCase.verifyEqual(v_error,v_error*0,'absTol',1e-13)
        end

        function test_mean_meas(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test mean sensor measurement calculation.
            % Validates that computed mean accelerometer and gyroscope 
            % values match the expected mean over 6-sample windows from 
            % input sensor data.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
             % Extract relevant input and output data from test case structure
            input = squeeze(testCase.data.mean_in(:,:,2:end));
            mean_acc = squeeze(testCase.data.mean_acc(:,:,2:end));
            mean_gyro = squeeze(testCase.data.mean_omega(:,:,2:end));

            % Initialize expected output array
            expected_mean = zeros(3,size(mean_acc,2)-1);

            % Compute expected means over 6-sample windows
            j=0;
            for i =6:6:length(input)
                j=j+1;
                expected_mean(:,j) = mean((input(:,i-5:i)),2);
            end

            % Verify the computed means match expected results
            testCase.verifyEqual(mean_acc,expected_mean,'absTol',1e-15)
            testCase.verifyEqual(mean_gyro,expected_mean,'absTol',1e-15)
        end

    end

end