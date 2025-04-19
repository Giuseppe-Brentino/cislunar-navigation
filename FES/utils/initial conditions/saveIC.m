function Spacecraft = saveIC(Spacecraft,x,v)

Spacecraft.x0.nominal = x;
Spacecraft.x0.unit = 'km';
Spacecraft.x0.description = 'Initial position of the spacecraft in MCI';
Spacecraft.v0.nominal = v;
Spacecraft.v0.unit = 'km/s';
Spacecraft.v0.description = 'Initial velocity of the spacecraft in MCI';

h = cross(x,v);
A2 = -h'/norm(h);
A3 = -x'/norm(x);
A1 = cross(A2,A3);
A = [A1;A2;A3];
q0_t = dcm2quat(A)';

Spacecraft.q0.value = [q0_t(2:4);q0_t(1)];
Spacecraft.q0.unit = '';
Spacecraft.q0.description = 'Initial attitude of the spacecraft w.r.t MCI';

end

