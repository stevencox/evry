import numpy as np
import math
import traceback

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

def simulate ():
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



t = np.linspace(0.0, 365.0, 29200) # times at which to calculate the light curve
m = batman.TransitModel(params, t) # initializes the model
f = m.light_curve(params)

# add gaussian error 
rs = np.random.RandomState(seed=13)

errors = 0.002*np.ones_like(f)
f += errors*rs.randn(len(t))

'''
'''
qms = [
    [ 128,               64 ],
    [ 64,                32 ],
    [ 32,                16 ],
    [ 16,                8 ],
    [ 8,                 4 ],
    [ 4,                 2 ],
    [ 2,                 1 ],
    [ 1,                 0.5 ],
    [ 0.5,               0.25 ],
    [ 0.25,              0.125 ],
    [ 0.125,            0.0625 ],
    [ 0.0625,          0.03125 ],
    [ 0.03125,        0.015625 ],
    [ 0.015625,      0.0078125 ],
    [ 0.0078125,    0.00390625 ],
    [ 0.00390625,  0.001953125 ]
]

for q in reversed (qms):
    qmax, qmin = q
    print ("qmin {0} qmax {1}".format (qmin, qmax))
    b=BLSRun (t=t, f=f, qmi=qmin, qma=qmax, fmin=0.3, df=0.001, nf=1000, nb=200)
    try:
        b.run ()
    except:
        traceback.print_exc ()

'''
(env)[scox@mac~/dev/bls]$ python bls.py
/Users/scox/dev/bls/env/lib/python2.7/site-packages/matplotlib/font_manager.py:273: UserWarning: Matplotlib is building the font cache using fc-list. This may take a moment.
  warnings.warn('Matplotlib is building the font cache using fc-list. This may take a moment.')
qmin 0.001953125 qmax 0.00390625
   bls( len(t)=29200, len(f)=29200, qmi=0.001953125, qma=0.00390625, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 49.3 sec
qmin 0.00390625 qmax 0.0078125
   bls( len(t)=29200, len(f)=29200, qmi=0.00390625, qma=0.0078125, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 42.99 sec
qmin 0.0078125 qmax 0.015625
   bls( len(t)=29200, len(f)=29200, qmi=0.0078125, qma=0.015625, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 41.58 sec
qmin 0.015625 qmax 0.03125
   bls( len(t)=29200, len(f)=29200, qmi=0.015625, qma=0.03125, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 41.82 sec
qmin 0.03125 qmax 0.0625
   bls( len(t)=29200, len(f)=29200, qmi=0.03125, qma=0.0625, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 42.74 sec
qmin 0.0625 qmax 0.125
   bls( len(t)=29200, len(f)=29200, qmi=0.0625, qma=0.125, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 43.93 sec
qmin 0.125 qmax 0.25
   bls( len(t)=29200, len(f)=29200, qmi=0.125, qma=0.25, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 46.77 sec
qmin 0.25 qmax 0.5
   bls( len(t)=29200, len(f)=29200, qmi=0.25, qma=0.5, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 54.34 sec
qmin 0.5 qmax 1
bls.py:91: RuntimeWarning: divide by zero encountered in double_scalars
  powo = s*s/(rn1*(rn - rn1))
bls.py:109: RuntimeWarning: divide by zero encountered in double_scalars
  high = -s3/(rn - rn3)
bls.py:115: RuntimeWarning: invalid value encountered in double_scalars
  sde = (bpow - np.mean(p))/np.std(p) # signal detection efficiency
/Users/scox/dev/bls/env/lib/python2.7/site-packages/numpy/core/_methods.py:101: RuntimeWarning: invalid value encountered in subtract
  x = asanyarray(arr - arrmean)
   bls( len(t)=29200, len(f)=29200, qmi=0.5, qma=1, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 64.82 sec
qmin 1 qmax 2
   bls( len(t)=29200, len(f)=29200, qmi=1, qma=2, fmin=0.3, df=0.001, nf=1000, nb=200 ) => time: 89.27 sec
qmin 2 qmax 4
Traceback (most recent call last):
  File "bls.py", line 215, in <module>
    b.run ()
  File "bls.py", line 147, in run
    res = bls(self.t, self.f, self.qmi, self.qma, self.fmin, self.df, self.nf, self.nb)
  File "bls.py", line 117, in bls
    return bpow, in1, in2, qtran, depth, bper, sde, p, high, low
UnboundLocalError: local variable 'in1' referenced before assignment

'''
