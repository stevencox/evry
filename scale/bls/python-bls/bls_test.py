import bls
import numpy as np
import batman
import astropy.units as u
from astropy.constants import G, R_sun, M_sun, R_jup, M_jup
import time as time_mod

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

r=1
time=np.linspace(0.0, 365.0, 29200)

m = batman.TransitModel(params, time) # initializes the model
flux = m.light_curve(params)

rs = np.random.RandomState(seed=13)        
errors = 0.002*np.ones_like(flux)
flux += errors*rs.randn(len(time))

qmi=0.0025
qma=0.01
fmin=0.3
df=0.001
nf=1000
nb=200
u = np.zeros(len(time))
v = np.zeros(len(time))

qms = [
    [ 128,               64 ],
    [ 64,                32 ],
    [ 32,                16 ],
    [ 16,                8 ],
    [ 8,                 4 ],
    [ 4,                 2 ],
    [ 2,                 1 ],
#-- crash
    [ 1,                 0.5 ],
#-- meaningful
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
    qma, qmi = q
    start = time_mod.time ()
    results = bls.eebls(time, flux, u, v, nf, fmin, df, nb, qmi, qma)
    elapsed = time_mod.time () - start
    print "qmi=>{0} qma=>{1} time=>{2} results=>{3}".format (qmi, qma, elapsed, results)

