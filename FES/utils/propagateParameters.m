function propagateParameters
    params = getParameters('Scenario.sldd',{'time','Environment'});
    time = params{1};
    Environment = params{2};
    [eul, eul_dot, jd_interval] = moonOrientation(Environment.Date,time.value);
    
    Environment.Moon.orientation = eul;
    Environment.Moon.orientation_dot = eul_dot;
    Environment.Moon.jd_interval = jd_interval;
 
    updateParameters('Scenario.sldd',{'Environment'},{Environment});
end

