classdef test_IMU < matlab.unittest.TestCase

    properties
        idealSensor
        gyroscope
    end
    methods(TestClassSetup)
        % Shared setup for the entire test class

        function initSensor(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialize Gyroscope Sensor
            % This function retrieves gyroscope parameters from the IMU
            % configuration and initializes an ideal sensor model with no
            % errors.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Retrieve IMU gyroscope parameters
            data = getParameters('Sensors.sldd',{'IMU'});
            testCase.gyroscope = data{1}.gyroscope;

            % Initialize an ideal sensor with zero errors
            testCase.idealSensor = testCase.gyroscope;
            testCase.idealSensor.bias.std = 0;
            testCase.idealSensor.nonLinearitySlope.value = 0;
            testCase.idealSensor.scaleFactor.std = 0;
            testCase.idealSensor.misalignment.std = 0;
            testCase.idealSensor.nonOrthogonality.std = 0;
        end
    end

    methods(Test)
        % Test methods

        function test_gErrors(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Gyroscope g-related Errors
            % This function verifies that the simulated gyroscope g-related
            % errors match the expected values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Retrieve IMU gyroscope parameters
            gyro = testCase.gyroscope;

            % Run the gyroscope error simulation
            simulation = sim("Models\IMU\g_errors.slx",'srcWorkspace','current');

            % Extract simulated gyroscope errors
            actual_errors = simulation.simout;

            % Compute expected gyroscope errors
            expected_error = gyro.biasG.value + 2*gyro.scaleFactorG.value;
            expected_errors = expected_error*ones(1,3);

            % Verify that the actual errors match expected values
            testCase.verifyEqual(actual_errors,expected_errors)
        end

        function test_nonLinearity(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test IMU Non-Linearity
            % This function verifies that the non-linearity error in the
            % imu measurement matches the expected values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Set random seed for reproducibility
            rng('default')

            % Configure sensor with non-linearity error from gyroscope parameters
            sensor = testCase.idealSensor;
            sensor.nonLinearitySlope.value = testCase.gyroscope.nonLinearitySlope.value;

            % Run simulation
            simulation = sim("Models\IMU\systematic_errors.slx",'srcWorkspace','current');

            % Compute actual error from simulation output
            actual_error = (simulation.simout - ones(1,3))';

            % Compute expected non-linearity error
            expected_error = diag(sensor.nonLinearitySlope.value*ones(3,1))*ones(3,1).^3;

            % Verify that the actual error matches the expected error within tolerance
            testCase.verifyEqual(actual_error,expected_error,'absTol',1e-16);
        end

        function test_bias(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test IMU Bias
            % This function verifies that the imu bias follows the
            % expected distribution by running multiple simulations and
            % comparing the mean and standard deviation of the bias error
            % with their expected values
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Set random seed for reproducibility
            rng('default')

            % Configure sensor with gyroscope bias standard deviation
            sensor = testCase.idealSensor;
            sensor.bias.std = testCase.gyroscope.bias.std;

            % Number of Monte Carlo simulations
            Nsim = 2000;

            % Load the systematic errors model
            load_system('Models\IMU\systematic_errors.slx')

            % Set up parallel simulations with varying sensor biases
            simIn(1:Nsim) = Simulink.SimulationInput('systematic_errors');
            for i = 1:Nsim
                simIn(i) = simIn(i).setVariable('sensor',sensor);
            end

            % Run parallel simulations
            simulation = parsim(simIn,UseFastRestart="on");

            % Extract simulation errors
            actual_errors = zeros(Nsim,3);
            for i = 1:Nsim
                actual_errors(i,:) = simulation(i).simout - ones(1,3);
            end

            % Compute mean and standard deviation of errors
            mean_error = mean(actual_errors);
            std_error = std(actual_errors);

            % Expected bias error statistics
            expected_mean = zeros(1,3);
            expected_std  = sensor.bias.std*ones(1,3);

            % Verify mean error is within expected tolerance
            testCase.verifyEqual(mean_error,expected_mean,'absTol',sensor.bias.std/10)

            % Verify standard deviation matches expected value within tolerance
            testCase.verifyEqual(std_error,expected_std,'relTol',5e-2)

            % Ensure biases are not identical across axes
            testCase.verifyNotEqual(mean_error(1),mean_error(2))
            testCase.verifyNotEqual(mean_error(3),mean_error(2))
            testCase.verifyNotEqual(mean_error(1),mean_error(3))

        end

        function test_scaleFactor(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test IMU Scale Factor
            % This function verifies that the imu scale factor error
            % follows the expected distribution by running multiple
            % simulations and comparing the mean and standard deviation of
            % the scale factor error with their expected values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Set random seed for reproducibility
            rng('default')

            % Configure sensor with gyroscope scale factor standard deviation
            sensor = testCase.idealSensor;
            sensor.scaleFactor.std = testCase.gyroscope.scaleFactor.std;

            % Number of Monte Carlo simulations
            Nsim = 2000;

            % Load the systematic errors model
            load_system('Models\IMU\systematic_errors.slx')

            % Set up parallel simulations with varying sensor scale factors
            simIn(1:Nsim) = Simulink.SimulationInput('systematic_errors');
            for i = 1:Nsim
                simIn(i) = simIn(i).setVariable('sensor',sensor);
            end

            % Run parallel simulations
            simulation = parsim(simIn,UseFastRestart="on");

            % Extract simulation errors
            actual_errors = zeros(Nsim,3);
            for i = 1:Nsim
                actual_errors(i,:) = simulation(i).simout - ones(1,3);
            end

            % Compute mean and standard deviation of errors
            mean_error = mean(actual_errors);
            std_error = std(actual_errors);

            % Expected scale factor error statistics
            expected_mean = zeros(1,3);
            expected_std  = sensor.scaleFactor.std*ones(1,3);

            % Verify mean error is within expected tolerance
            testCase.verifyEqual(mean_error,expected_mean,'absTol',sensor.scaleFactor.std/10)

            % Verify standard deviation matches expected value within tolerance
            testCase.verifyEqual(std_error,expected_std,'relTol',5e-2)

            % Ensure scale factor errors are not identical across axes
            testCase.verifyNotEqual(mean_error(1),mean_error(2))
            testCase.verifyNotEqual(mean_error(3),mean_error(2))
            testCase.verifyNotEqual(mean_error(1),mean_error(3))
        end

        function test_nonOrthogonality(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test IMU Non-Orthogonality
            % This function verifies that the imu non-orthogonality errors
            % follow the expected distribution by running multiple
            % simulations and comparing the mean and standard deviation of
            % the error with their expected values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Set random seed for reproducibility
            rng('default')

            % Configure sensor with gyroscope non-orthogonality standard deviation
            sensor = testCase.idealSensor;
            sensor.nonOrthogonality.std = testCase.gyroscope.nonOrthogonality.std;

            % Number of Monte Carlo simulations
            Nsim = 2000;

            % Load the systematic errors model
            load_system('Models\IMU\systematic_errors.slx')

            % Set up parallel simulations with varying sensor non-orthogonality errors
            simIn(1:Nsim) = Simulink.SimulationInput('systematic_errors');
            for i = 1:Nsim
                simIn(i) = simIn(i).setVariable('sensor',sensor);
            end

            % Run parallel simulations
            simulation = parsim(simIn,UseFastRestart="on");

            % Extract simulation errors
            actual_errors = zeros(Nsim,3);
            for i = 1:Nsim
                actual_errors(i,:) = simulation(i).simout - ones(1,3);
            end

            % Compute mean and standard deviation of errors
            mean_error = mean(actual_errors);
            std_error = std(actual_errors);

            % Expected non-orthogonality error statistics
            expected_mean = zeros(1,3);
            expected_std  = sqrt(2)*sensor.nonOrthogonality.std*ones(1,3);

            % Verify mean error is within expected tolerance
            testCase.verifyEqual(mean_error,expected_mean,'absTol',sensor.nonOrthogonality.std/10)

            % Verify standard deviation matches expected value within tolerance
            testCase.verifyEqual(std_error,expected_std,'relTol',5e-2)

            % Ensure non-orthogonality errors are not identical across axes
            testCase.verifyNotEqual(mean_error(1),mean_error(2))
            testCase.verifyNotEqual(mean_error(3),mean_error(2))
            testCase.verifyNotEqual(mean_error(1),mean_error(3))
        end

        function test_misalignment(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test IMU Misalignment
            % This function verifies that the imu misalignment errors
            % follow the expected distribution by running multiple
            % simulations and comparing the mean and standard deviation of
            % the error with their expected values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Set random seed for reproducibility
            rng('default')

            % Configure sensor with gyroscope misalignment standard deviation
            sensor = testCase.idealSensor;
            sensor.misalignment.std = testCase.gyroscope.misalignment.std;

            % Number of Monte Carlo simulations
            Nsim = 2000;

            % Load the systematic errors model
            load_system('Models\IMU\systematic_errors.slx')

            % Set up parallel simulations with varying sensor misalignment errors
            simIn(1:Nsim) = Simulink.SimulationInput('systematic_errors');
            for i = 1:Nsim
                simIn(i) = simIn(i).setVariable('sensor',sensor);
            end

            % Run parallel simulations
            simulation = parsim(simIn,UseFastRestart="on");

            % Extract simulation errors
            actual_errors = zeros(Nsim,3);
            for i = 1:Nsim
                actual_errors(i,:) = simulation(i).simout - ones(1,3);
            end

            % Compute mean and standard deviation of errors
            mean_error = mean(actual_errors);
            std_error = std(actual_errors);

            % Expected misalignment error statistics
            expected_mean = zeros(1,3);
            expected_std  = sqrt(2)*sensor.misalignment.std*ones(1,3);

            % Verify mean error is within expected tolerance
            testCase.verifyEqual(mean_error,expected_mean,'absTol',sensor.misalignment.std/10)

            % Verify standard deviation matches expected value within tolerance
            testCase.verifyEqual(std_error,expected_std,'relTol',5e-2)

            % Ensure misalignment errors are not identical across axes
            testCase.verifyNotEqual(mean_error(1),mean_error(2))
            testCase.verifyNotEqual(mean_error(3),mean_error(2))
            testCase.verifyNotEqual(mean_error(1),mean_error(3))
        end

        function test_accelerationTransport(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Acceleration Transport
            % This function verifies that the acceleration transport model
            % correctly accounts for linear and rotational motion effects,
            % ensuring the computed acceleration matches expected
            % theoretical values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Retrieve IMU sensor parameters
            data = getParameters('Sensors.sldd',{'IMU'});
            IMU = data{1};

            % Align imu with body axes (rotation matrix already tested)
            IMU.orientation.value = zeros(3,1);

            % Run simulation
            simulation = sim('Models\IMU\imu_acceleration.slx','srcWorkspace','current');

            % Extract actual measured acceleration from simulation
            actual_acc = simulation.acc;

            % Compute expected acceleration based on motion dynamics
            position = repmat(IMU.position.value,[1,1,size(actual_acc,3)]);
            expected_acc = ones(3,1,size(actual_acc,3)) + ...
                cross(simulation.w,cross(simulation.w,position,1),1) + ...
                cross(simulation.w_dot,position);

            % Verify that the computed acceleration matches the expected acceleration
            testCase.verifyEqual(actual_acc,expected_acc)
        end

    end

end