classdef test_SH < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_sphericalHarmonics(testCase)
            fun = sphericalHarmonics;
            p = getParameters('Scenario.sldd',{'TestData'});
            TestData = p{1};
            fun.body_coeffs = TestData.SH;
            fun.mu = TestData.SH.mu.value;
            fun.ref_radius = TestData.SH.ref_radius.value;
            fun.nMax = TestData.SH.n.value;
            fun.mMax = TestData.SH.m.value;
            position = [5489150, 802222, 3140916]';

            [actual_g,~,~] = fun.getGravity(position);
            expected_g = [-8.44260633555472;-1.23393243051834; -4.84652486332608];
            verifyEqual(testCase,actual_g,expected_g,'RelTol',1e-10)

        end
    end

end