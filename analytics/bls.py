import numpy as np
import math

import batman #install batman-package (Bad-Ass Transit Model cAlculatioN)
import astropy.units as u
from astropy.constants import G, R_sun, M_sun, R_jup, M_jup

import time

def bls(t, x, qmi, qma, fmin, df, nf, nb):
    """Frist trial, BLS algorithm, only minor modification from author's code"""
    
    n = len(t); rn = len(x)
    #! use try
    if n != rn:
        print "Different size of array, t and x"
        return 0

    rn = float(rn) # float of n

    minbin = 5
    nbmax = 2000
    if nb > nbmax:
        print "Error: NB > NBMAX!"
        return 0

    tot = t[-1] - t[0] # total time span

    if fmin < 1.0/tot:
        print "Error: fmin < 1/T"
        return 0

    # parameters in binning (after folding)
    kmi = int(qmi*nb) # nb is number of bin -> a single period
    if kmi < 1: 
        kmi = 1
    kma = int(qma*nb) + 1
    kkmi = rn*qmi # to check the bin size
    if kkmi < minbin: 
        kkmi = minbin

    # For the extension of arrays (edge effect: transit happen at the edge of data set)
    nb1 = nb + 1
    nbkma = nb + kma
        
    # Data centering
    t1 = t[0]
    u = t - t1
    s = np.mean(x) # ! Modified
    v = x - s

    bpow = 0.0
    p = np.zeros(nf)
    # Start period search
    for jf in range(nf):
        f0 = fmin + df*jf # iteration in frequency not period
        p0 = 1.0/f0

        # Compute folded time series with p0 period
        ibi = np.zeros(nbkma)
        y = np.zeros(nbkma)
        for i in range(n):
            ph = u[i]*f0 # instead of t mod P, he use t*f then calculate the phase (less computation)
            ph = ph - int(ph)
            j = int(nb*ph) # data to a bin 
            ibi[j] = ibi[j] + 1 # number of data in a bin
            y[j] = y[j] + v[i] # sum of light in a bin
        
        # Extend the arrays  ibi()  and  y() beyond nb by wrapping
        for j in range(nb1, nbkma):
            jnb = j - nb
            ibi[j] = ibi[jnb]
            y[j] = y[jnb]

        # Compute BLS statictics for this trial period
        power = 0.0

        for i in range(nb): # shift the test period
            s = 0.0
            k = 0
            kk = 0
            nb2 = i + kma
            # change the size of test period (from kmi to kma)
            for j in range(i, nb2): 
                k = k + 1
                kk = kk + ibi[j]
                s = s + y[j]
                if k < kmi: continue # only calculate SR for test period > kmi
                if kk < kkmi: continue # 
                rn1 = float(kk)
                powo = s*s/(rn1*(rn - rn1))
                if powo > power: # save maximum SR in a test period
                    power = powo # SR value
                    jn1 = i # 
                    jn2 = j
                    rn3 = rn1
                    s3 = s

        power = math.sqrt(power)
        p[jf] = power

        if power > bpow:
            bpow = power # Save the absolute maximum of SR
            in1 = jn1
            in2 = jn2
            qtran = rn3/rn
            # depth = -s3*rn/(rn3*(rn - rn3))
            # ! Modified
            high = -s3/(rn - rn3)
            low = s3/rn3
            depth = high - low
            bper = p0
    
    # ! add
    sde = (bpow - np.mean(p))/np.std(p) # signal detection efficiency

    return bpow, in1, in2, qtran, depth, bper, sde, p, high, low

params = batman.TransitParams() # object to store the transit parameters
params.t0 = 1.0 # time of inferior conjunction 
params.per = 2.0 # orbital period (days)
params.rp = R_jup/R_sun # planet radius (in units of stellar radii)

# calculate semi-major axis from orbital period value
a = (((params.per*u.day)**2 * G * (M_sun + M_jup) / (4*np.pi**2))**(1./3)).to(R_sun).value 

params.a = a # semi-major axis (in units of stellar radii)
params.inc = 90.0  # orbital inclination (in degrees)
params.ecc = 0. # eccentricity
params.w = 90. # longitude of periastron (in degrees), 90 for circular
params.u = [0.1, 0.3] # limb darkening coefficients
params.limb_dark = "quadratic" # limb darkening model


class BLSRun (object):
    def __init__(self, t, f, qmi, qma, fmin, df, nf, nb):
        self.t = t
        self.f = f
        self.qmi = qmi
        self.qma = qma
        self.fmin = fmin
        self.df = df
        self.nf = nf
        self.nb = nb
    def run (self):
        start = time.time ()
        res = bls(self.t, self.f, self.qmi, self.qma, self.fmin, self.df, self.nf, self.nb)
        elapsed = time.time () - start
        print ("   bls( {0} ) => time: {1} sec".format (self, round (elapsed, 2)))
    def __str__(self):
        return self.__repr__()
    def __repr__(self):
        return "len(t)={0}, len(f)={1}, qmi={2}, qma={3}, fmin={4}, df={5}, nf={6}, nb={7}".format (
            len(self.t), len(self.f), self.qmi, self.qma, self.fmin, self.df, self.nf, self.nb)

runs = []

for r in range(1, 10):
    t = np.linspace(0.0, 6.0, 1000 * r) # times at which to calculate the light curve
    m = batman.TransitModel(params, t) # initializes the model
    f = m.light_curve(params)
    
    # add gaussian error 
    rs = np.random.RandomState(seed=13)
    
    errors = 0.002*np.ones_like(f)
    f += errors*rs.randn(len(t))

    base = 0.005
    for max_fac in [ 1, 10, 100 ]:
        run = BLSRun (t=t, f=f, qmi=base, qma=base * max_fac, fmin=0.3, df=0.001, nf=1000, nb=200)
        runs.append (run)

    print ("r {0}".format (r))
    for run in runs:
        run.run ()

    runs = []
