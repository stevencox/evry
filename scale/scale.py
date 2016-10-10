from __future__ import print_function, division
import numba
from nufftpy import nufft1
import argparse
import numpy as np
import math
import traceback
import bls as python_bls
import time
import batman #install batman-package (Bad-Ass Transit Model cAlculatioN)
import astropy.units as u
from astropy.constants import G, R_sun, M_sun, R_jup, M_jup

def bls(t, x, qmi, qma, fmin, df, nf, nb):
    """Frist trial, BLS algorithm, only minor modification from author's code"""
    
    n = len(t); rn = len(x)
    #! use try
    if n != rn:
        print ("Different size of array, t and x")
        return 0

    rn = float(rn) # float of n

    minbin = 5
    nbmax = 2000
    if nb > nbmax:
        print ("Error: NB > NBMAX!")
        return 0

    tot = t[-1] - t[0] # total time span

    if fmin < 1.0/tot:
        print ("Error: fmin < 1/T")
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
qms = [
    [ 0.5,               0.25 ],
    [ 0.25,              0.125 ],
    [ 0.125,            0.0625 ],
    [ 0.0625,          0.03125 ],
    [ 0.03125,        0.015625 ],
    [ 0.015625,      0.0078125 ],
    [ 0.0078125,    0.00390625 ],
    [ 0.00390625,  0.001953125 ]
]

fmin=0.3
df=0.001
nf=1000
nb=200

def test_python_bls ():
    for q in reversed (qms):
        qmax, qmin = q
        print ("qmin {0} qmax {1}".format (qmin, qmax))
        b=BLSRun (t=t, f=f, qmi=qmin, qma=qmax, fmin=fmin, df=df, nf=nf, nb=nb)
        try:
            b.run ()
        except:
            traceback.print_exc ()

def test_original_bls ():
    # python-bls (fortran wrapper)
    u = np.zeros(len(t))
    v = np.zeros(len(t))
    for q in reversed (qms):
        qma, qmi = q
        start = time.time ()
        results = python_bls.eebls(t, f, u, v, nf, fmin, df, nb, qmi, qma)
        elapsed = time.time () - start
        results = []
        print ("qmi=>{0} qma=>{1} results=>{2} time=>{3}".format (qmi, qma, results, elapsed))

# -- NUFFT:

@numba.jit(nopython=True)
def build_grid_fast(x, c, tau, Msp, ftau, E3):
    Mr = ftau.shape[0]
    hx = 2 * np.pi / Mr
    
    # precompute some exponents
    for j in range(Msp + 1):
        E3[j] = np.exp(-(np.pi * j / Mr) ** 2 / tau)
        
    # spread values onto ftau
    for i in range(x.shape[0]):
        xi = x[i] % (2 * np.pi)
        m = 1 + int(xi // hx)
        xi = (xi - hx * m)
        E1 = np.exp(-0.25 * xi ** 2 / tau)
        E2 = np.exp((xi * np.pi) / (Mr * tau))
        E2mm = 1
        for mm in range(Msp):
            ftau[(m + mm) % Mr] += c[i] * E1 * E2mm * E3[mm]
            E2mm *= E2
            ftau[(m - mm - 1) % Mr] += c[i] * E1 / E2mm * E3[mm + 1]
    return ftau

def nufftfreqs(M, df=1):
    """Compute the frequency range used in nufft for M frequency bins"""
    return df * np.arange(-(M // 2), M - (M // 2))

def _compute_grid_params(M, eps):
    # Choose Msp & tau from eps following Dutt & Rokhlin (1993)
    if eps <= 1E-33 or eps >= 1E-1:
        raise ValueError("eps = {0:.0e}; must satisfy "
                         "1e-33 < eps < 1e-1.".format(eps))
    ratio = 2 if eps > 1E-11 else 3
    Msp = int(-np.log(eps) / (np.pi * (ratio - 1) / (ratio - 0.5)) + 0.5)
    Mr = max(ratio * M, 2 * Msp)
    lambda_ = Msp / (ratio * (ratio - 0.5))
    tau = np.pi * lambda_ / M ** 2
    return Msp, Mr, tau

def nufft_numba_fast(x, c, M, df=1.0, eps=1E-15, iflag=1):
    """Fast Non-Uniform Fourier Transform with Numba"""
    Msp, Mr, tau = _compute_grid_params(M, eps)
    N = len(x)
    
    # Construct the convolved grid
    ftau = build_grid_fast(x * df, c, tau, Msp,
                           np.zeros(Mr, dtype=c.dtype),
                           np.zeros(Msp + 1, dtype=x.dtype))

    # Compute the FFT on the convolved grid
    if iflag < 0:
        Ftau = (1 / Mr) * np.fft.fft(ftau)
    else:
        Ftau = np.fft.ifft(ftau)
    Ftau = np.concatenate([Ftau[-(M//2):], Ftau[:M//2 + M % 2]])

    # Deconvolve the grid using convolution theorem
    k = nufftfreqs(M)
    return (1 / N) * np.sqrt(np.pi / tau) * np.exp(tau * k ** 2) * Ftau

def test_nufft ():
    #https://jakevdp.github.io/blog/2015/02/24/optimizing-python-with-numpy-and-numba/
    #Mrange = (2 ** np.arange(3, 18)).astype(int)
    minimum_frequency=1 / 1024
    maximum_frequency=1 / 0.00138889
    grid_sizes = [ 0.0013, 0.001953125, 0.00390625, 0.0078125, 0.015625, 0.03125, 0.0625, 0.125, 0.25, 0.5, 1, 2 ]
    with open ("nufft.out", "w") as stream:
        for grid_size in grid_sizes:
            nbins = (maximum_frequency - minimum_frequency) / grid_size
            Mrange = np.linspace(minimum_frequency, maximum_frequency, nbins)
            stream.write ("grid_size: {0}".format (grid_size))
            for M in Mrange:
                stream.write ("M: {0}".format (M))
                x = np.random.uniform(low=0.0, high=M, size=(29200,))
                c = np.sin(x)
                start = time.time ()
                r = nufft_numba_fast(x, c, M)
                elapsed = time.time () - start
                stream.write ("====> time: {0} secs: M={1}\n {2}\n".format (elapsed, M, r))

def main ():
    parser = argparse.ArgumentParser()
    parser.add_argument("--python",  help="Test the all Python BLS implementation", action='store_true')
    parser.add_argument("--eebls",  help="Test Python wrapper around Kovac's Fortran BLS implementation", action='store_true')
    parser.add_argument("--nufft",  help="Time nufft", action='store_true')
    args = parser.parse_args()
    if args.python:
        test_python_bls ()
    elif args.eebls:
        test_original_bls ()
    elif args.nufft:
        test_nufft ()

main ()
