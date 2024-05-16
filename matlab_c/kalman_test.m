function filtered_values = kalman_test(measurements)
% function kalman_test
% measurements =  [89.5,89.5,89.75,89.75,90,89.75,89.75,89.75,90,89.75,90,89.75,89.75,89.75,89.75,89.5,89.5,89.5,89.5,89.5,89.5,89.5,89.5,89.5,89.25,89.25,89.5,89.5,89.25,89.25,89,89.25,89,89,88.75,89,89,89.25,89,89.25,89,89.25,89.25,89.5,89.5,89.25,89.5,89.5,89.5,89.5,89.5]; %[82.5,82.5,82.75,82.5,82.5,82.75,82.75,82.75,82.5,82.75,82.75,82.75,82.5,82.75,82.5,82.5,82.5,82.75,82.75,82.75,82.75,82.5,82.75,82.5,82.5,82.25,82.5,82.5,82.25,82.5,82.5,82.75,82.5,82.75,82.25,82.5,82.5,82.5,82.5,82.75,82.5,82.75,82.5,82.5,82.5,82.5,82.5,82.5,82.75,82.75,82.5,82.5,82.5];

filtered_values = zeros(1, numel(measurements));

coef.A = 1;
coef.B = 0;
coef.C = 1;
coef.process_noise = 0.0005;
coef.measurement_noise = 1;

reset = 1;

kalman_mex(0, coef.A, coef.B, coef.C, coef.process_noise, ...
    coef.measurement_noise, reset);

for i = 1:numel(measurements)
    filtered_values(i) = kalman_mex(measurements(i), ...
        coef.A, coef.B, coef.C, ...
        coef.process_noise, ...
        coef.measurement_noise);
end
end