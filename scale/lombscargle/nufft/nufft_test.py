from __future__ import print_function, division
import numba
from nufftpy import nufft1
import numpy as np
import time

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
#            x = 29200 * np.random.random (M)
            x = np.random.uniform(low=0.0, high=M, size=(29200,))
            c = np.sin(x)
            start = time.time ()
            r = nufft_numba_fast(x, c, M)
            elapsed = time.time () - start
            stream.write ("====> time: {0} secs: M={1}\n {2}\n".format (elapsed, M, r))
