#include "mex.h"
#include "KalmanFilter.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs < 6) {
        mexErrMsgIdAndTxt("MyToolbox:kalman_mex:nrhs", "At least three inputs required (measurement, coefficients[1, 4]).");
    }

    // Create static instances to maintain the state of Kalman filter between calls
    static struct kalman_filter_t kf;
    static struct kalman_filter_coefficients_t coeff;
    static bool initialized = false;

    if(nrhs == 7) {
        if (mxGetScalar(prhs[6]) == 1) {

            kalman_filter_init(&kf);
            // Example coefficients, adjust as necessary
            coeff.matrix_A = mxGetScalar(prhs[1]);
            coeff.matrix_B = mxGetScalar(prhs[2]);
            coeff.matrix_C = mxGetScalar(prhs[3]);
            coeff.process_noise = mxGetScalar(prhs[4]);
            coeff.measurement_noise = mxGetScalar(prhs[5]);
            return;
        }
    }
    // Get the input measurement
    double measurement = mxGetScalar(prhs[0]);

    // Update the Kalman filter with the new measurement
    double filtered_output = kalman_filter(&kf, &coeff, measurement);

    // Set the output to MATLAB
    plhs[0] = mxCreateDoubleScalar(filtered_output);
}

