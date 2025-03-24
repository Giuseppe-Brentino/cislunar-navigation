classdef test_radio < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_delay(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Signal Delay
            % This function verifies that the delay in the signal is
            % correctly applied by comparing specific time instances in the
            % simulation output.
            %
            % The expected delayed signal values should match the
            % predefined expected values at the given time points.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Run simulation
            simulation = sim("Models\Radio\test_delay.slx");

            % Extract simulation output signal and time values
            signal = simulation.simout.Data;
            time = simulation.simout.Time;

            % Extract actual signal values at specified time points
            actual_points = [signal(time==11) signal(time==11.1)...
                signal(time==22) signal(time==22.1)];

            % Define expected signal values at the same time points
            expected_points = [1 11 11 21];

            % Verify that actual values match expected values
            testCase.verifyEqual(actual_points,expected_points)
        end

        function test_measurementUpdate(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Measurement Update
            % The function checks whether the timestamp and range values
            % are properly computed and updated when the signal is
            % received, ensuring consistency with expected results.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define timestamps of the spacecrafts positions
            time = 0:6;

            % Define the position of the transmitting spacecraft over time
            TX_data = [0 -101 0 0 0 0 -101;
                0 0 101 101 101 101 0;
                0 0 0 0 0 0 0];

            % Define the position of the receiving spacecraft over time
            RX_data = [zeros(3,1), [1000*ones(1,6);zeros(2,6)]];

            % Save the data into timeseries format
            RX = timeseries(RX_data,time);
            TX = timeseries(TX_data,time);

            % Moon radius
            R_M = 100;

            % Run simulation
            simulation = sim('Models\Radio\test_update.slx','srcWorkspace','current');

            % Extract simulation outputs
            timestamp = simulation.timestamp;
            range = simulation.range;

            % Verify timestamp updates correctly
            testCase.verifyTrue(all(timestamp.Data(timestamp.Time>=2)==2));
            testCase.verifyTrue(all(timestamp.Data(timestamp.Time<2)==0));

            % Verify range calculations are correct
            testCase.verifyTrue(all(range.Data(range.Time>=2)==sqrt(101^2+1000^2)));
            testCase.verifyTrue(all(range.Data(range.Time<2)==0));

        end

        function test_signalGeneration(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Signal Generation
            % This function verifies that the signal generation model
            % correctly computes the reception times (t1, t2) and
            % corresponding received signals (r1, r2).
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Run simulation
            simulation = sim("Models\Radio\test_signalGen.slx");

            % Extract simulation outputs
            t1 = simulation.t1;
            t2 = simulation.t2;
            r1 = simulation.r1;
            r2 = simulation.r2;

            % Expected values for t1 at key timestamps
            t1_expected = [0.1; 1.1; 2.1];

            % Verify t1 values are assigned correctly at different time intervals
            testCase.verifyTrue( all(t1.Data(t1.Time>=0.1 & t1.Time<1.1)==t1_expected(1)) );
            testCase.verifyTrue( all(t1.Data(t1.Time>=1.1 & t1.Time<2.1)==t1_expected(2)) );
            testCase.verifyTrue( all(t1.Data(t1.Time>=2.1 )==t1_expected(3)) );

            % Verify t2 values are correctly shifted by 0.1 with respect to
            % t1
            testCase.verifyTrue( all(t2.Data(t2.Time>=0.2 & t2.Time<1.1)==t1_expected(1)+0.1) );
            testCase.verifyEqual( t2.Data(t2.Time>=1.2 & t2.Time<2.1),...
                ones(length(t2.Data(t2.Time>=1.2 & t2.Time<2.1)),1)*(t1_expected(2)+0.1),...
                'absTol', 1e-15 );

            % Validate specific time instances for t2 using small tolerance
            % (when t1 is updated with a new measure, but t2 is still the
            % old one)
            testCase.verifyEqual( t2.Data(t2.Time==1.1), t1.Data(t1.Time==1.1)-0.9,'AbsTol',1e-14 );
            testCase.verifyEqual( t2.Data(t2.Time==2.1), t1.Data(t1.Time==2.1)-0.9, 'AbsTol',1e-14 );

            % Verify that r1 and r2 are computed correctly (they should be
            % equal to their timestamp in this case)
            testCase.verifyEqual(t1.Data,r1.Data,'AbsTol',1e-14);
            testCase.verifyEqual(t2.Data,r2.Data,'AbsTol',1e-14);

        end

        function test_CN0(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Carrier-to-Noise Ratio (C/N0)
            % This function verifies the correct implementation of the
            % Carrier-to-Noise ratio (C/N0) based on the given transmission
            % and receiver parameters and space loss calculations.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define signal parameters
            range = 100;      % km
            lambda = 0.1;     % m (wavelength)
            Pt = 15;          % dBW (transmit power)
            Gt = 10;          % dB (transmit antenna gain)
            Gr = 1;           % dB (receive antenna gain)
            N0 = -200.9;      % dB (thermal noise power)
            L = 2;            % dB (receiver losses)

            % Run simulation
            simulation = sim('Models/Radio/test_CN0.slx','srcWorkspace', 'current');

            % Extract actual simulation result
            actual = simulation.simout;

            % Compute expected C/N0 value
            L_space = 20*log10(lambda/(4*pi*(range*1000))); % Free-space path loss
            CN0_dB = Pt + Gt + L_space + Gr - N0 -L; % Compute C/N0 in dB
            expected = 10^( CN0_dB*0.1 ); % Convert to linear scale

            % Verify that the actual and expected results match
            testCase.verifyEqual(actual,expected)
        end

        function test_tDDL(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Delay Lock Loop (DLL) Noise Standard Deviation
            % This function verifies the standard deviation of the DLL
            % tracking error based on the Carrier-to-Noise ratio (C/N0).
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Load radio parameters
            radio = getParameters('Sensors.sldd',{'Radio'});
            data = radio{1}.PN;

            % Validation data, from: E. D. Kaplan and C. J. Hegarty,
            % Understanding GPS: Principles and Applications
            CN0_dB = 30.001913221101333;
            expected_std = 2.6322574919469705;

            % Convert C/N0 from dB to linear scale
            CN0 = 10^( CN0_dB*0.1 );

            % Run the simulation
            simulation = sim('Models/Radio/test_DLLNoise.slx','srcworkspace','current');

            % Extract actual standard deviation from simulation results
            actual_std = simulation.simout.Data;

            % Verify that the actual standard deviation matches the expected value
            testCase.verifyEqual(actual_std,expected_std,'absTol',1e-3)
        end

        function test_tPLL(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Phase-Locked Loop (PLL) Noise Standard Deviation
            % This function verifies the standard deviation of the PLL 
            % tracking error based on the Carrier-to-Noise ratio (C/N0).
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Load radio parameters
            radio = getParameters('Sensors.sldd',{'Radio'});
            data = radio{1};

            % Validation data, from: E. D. Kaplan and C. J. Hegarty,
            % Understanding GPS: Principles and Applications
            CN0_dB = 29.78576615831518;
            expected_std =8.413275946698140;

            % Convert C/N0 from dB to linear scale
            CN0 = 10^( CN0_dB*0.1 );

            % Run the simulation
            simulation = sim('Models/Radio/test_PLLNoise.slx','srcworkspace','current');

            % Extract actual standard deviation from simulation results
            actual_std = simulation.simout.Data;

            % Verify that the actual standard deviation matches the expected value
            testCase.verifyEqual(actual_std,expected_std,'absTol',1e-3)
        end

    end

end