classdef test_crossProductMatrix < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_cpMatrix(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test correctness of the cross product matrix block.
            % Verifies that ax * b produces the same result as cross(a, b).
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Data
            a = [7; 3.4; 6];
            b = [9; 13; 2.5];

            % Run the cross product matrix simulation
            testBlockOut = sim("Models\crossProductMat.slx",'srcWorkspace','current');
            ax = testBlockOut.ax;

            % Compute expected and actual cross product results
            expected = cross(a,b);
            actual = ax*b;

            % Verify output matches the expected cross product
            testCase.verifyEqual(actual,expected)
        end

    end

end