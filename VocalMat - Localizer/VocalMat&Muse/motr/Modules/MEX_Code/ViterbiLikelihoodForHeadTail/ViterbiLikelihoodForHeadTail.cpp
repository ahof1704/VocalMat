#include <stdio.h>
#include "mex.h"
#include <math.h>
const float PI = 3.14159265;
#define sigmoid(a) (1./(1+exp(-a)))

double bessi0(float x)
{
	double ax,ans;
	double y;

	if ((ax=fabs(x)) < 3.75) {
		y=x/3.75;
		y*=y;
		ans=1.0+y*(3.5156229+y*(3.0899424+y*(1.2067492
			+y*(0.2659732+y*(0.360768e-1+y*0.45813e-2)))));
	} else {
		y=3.75/ax;
		ans=(exp(ax)/sqrt(ax))*(0.39894228+y*(0.1328592e-1
			+y*(0.225319e-2+y*(-0.157565e-2+y*(0.916281e-2
			+y*(-0.2057706e-1+y*(0.2635537e-1+y*(-0.1647633e-1
			+y*0.392377e-2))))))));
	}
	return ans;
}
/* (C) Copr. 1986-92 Numerical Recipes Software 0!(5'R3. */

double fnVonMises(double Mue, double Kappa, double x) {
// Estimates the von Mises distribution at point x
double I0 = bessi0(Kappa);
return 1.0 / (2.0*PI*I0) * exp(Kappa * cos(x-Mue));

}

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 5 || nlhs != 1) {
    mexErrMsgTxt("Usage: [a2fLikelihood] = fnViterbiLikelihoodForHeadTail(afStateAngles, afHeadTailImageProb, afTheta, afVelocityPix, afVelocityAngle)");
	return;
  } 

	int iNumStates = mxGetNumberOfElements(prhs[0]);
	int iNumFrames = mxGetNumberOfElements(prhs[1]);

	double *afStateAngles = (double *)mxGetData(prhs[0]);	
	double *afHeadTailImageProb = (double *)mxGetData(prhs[1]);	
	double *afTheta= (double *)mxGetData(prhs[2]);	
	double *afVelocityPix= (double *)mxGetData(prhs[3]);	
	double *afVelocityAngle = (double *)mxGetData(prhs[4]);	
	// Create output
	int  dim_array[2];  
	dim_array[0] = iNumStates;
	dim_array[1] = iNumFrames;
	plhs[0] = mxCreateNumericArray(2, dim_array, mxDOUBLE_CLASS, mxREAL);
	double *a2fLikelihood = (double*)mxGetPr(plhs[0]);

	double fDeltaAngle = afStateAngles[1]-afStateAngles[0];

	double fMinimumReliableWalkingSpeedPixels = 6;
	double fKappaSlopeParameter = 2;
	double fMaxKappa = 100;  // roughly +- 20 degrees
	double fMeasurementErrorKappa = 100; // roughly +- 45 degrees

  for (int iFrameIter=0;iFrameIter < iNumFrames;iFrameIter++) {
	  for (int iStateIter = 0; iStateIter < iNumStates; iStateIter++) {

        double fStateAngle = afStateAngles[iStateIter];
        
        // P(+|x)/P(-|x) == p(x|+)/p(x|-) for a two-class "Bayesian" classifier with
	    // P(+)==P(-).  (By a "Bayesian" classifer, I mean one where P(+|x) and P(-|x) are 
	    // determined from p(x|+) and p(x|-) using Bayes rule.
        // And since the likelihoods we calculate here only matter up to a constant
        // factor, that means we can use P(+|x) in place of p(x|+), and P(-|x) in place
        // of p(x|-).        
        double fLikelihoodBlobImage = fDeltaAngle * (
            afHeadTailImageProb[iFrameIter] * fnVonMises(
            fStateAngle, fMeasurementErrorKappa, afTheta[iFrameIter]) + 
        (1-afHeadTailImageProb[iFrameIter]) * fnVonMises(
        fStateAngle+PI, fMeasurementErrorKappa, afTheta[iFrameIter]));

        /*
        % Velocity Likelihood:
        % The model here is a single circular gaussian, centered at the
        % true state with "standard deviation" (kappa) that is controlled
        % by the speed. I.e., if the speed is low, the probability of
        % observing any given velocity angle is pretty much the same, but
        % as the speed increases, the probability of seeing velocity angles
        % that are closer to the true mouse direction getts narrow and
        % narrow.
        % This is controlled by three parameters that transform the
        % velocity (any value), first to [0,1] and then to [0..fMaxKappa]
		*/
/*
        double fLikelihoodVelocity = 1;
        if (afVelocityPix[iFrameIter] > fMinimumReliableWalkingSpeedPixels) {
             fLikelihoodVelocity = fnVonMises(fStateAngle, 200, afVelocityAngle[iFrameIter]) * fDeltaAngle;
        }
  */          
            
        double fVelocityKappa = fMaxKappa * 
			sigmoid( fKappaSlopeParameter*(afVelocityPix[iFrameIter] - fMinimumReliableWalkingSpeedPixels));
                
        double fLikelihoodVelocity = ( fnVonMises(fStateAngle, 
            fVelocityKappa, afVelocityAngle[iFrameIter]) * fDeltaAngle);
        



	  	  a2fLikelihood[iStateIter+iFrameIter*iNumStates] = log10(fLikelihoodVelocity) + log10(fLikelihoodBlobImage);	  
      }
  }

    
}

