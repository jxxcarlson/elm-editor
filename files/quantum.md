# Propagation and Evolution


## The propagator

Consider a wave function $\\psi(x,t)$.
If we fix $t$ and let $x$ vary, the
result is an element $\\psi(t)$ of
$L^2(R)$ or, more generally
$L^2(\\text{configuration space})$.
Thus the evolution of our system in
time is given by a function
$t \\mapsto \\psi(t)$.  The dynamics
of this path in Hilbert space is
governed by an ordinary differential
equation ,

$$
i\\hbar\\frac{d\\psi}{dt} = H\\phi,
$$

Now consider bases of orthogonal
normalized states
$\\{\\; \\psi_k(t_1)\\;\\}$ and
$\\{\\; \\psi_k(t_0) \\; \\}$
at times $t_1$ and $t_0$,
with $t_1 > t_0$. There is a unique linear
transformation $U(t_1,t_0)$
such that
$\\psi_k(t_1) = U(t_1,t_0)\\psi_k(t_0)$
for all $k$.
It must be unitary because the bases
are orthonormal.
This family of transformations is
called the \\term{propagator}.
The propagator satisfies various
identities, e.g., the composition law

$$
U(t_2, t_0) = U(t_2, t_1)U(t_1, t_0)
$$

as well as $U(t,t) = 1$,
$U(t_1,t_2) = U(t_2,t_1)^{-1}$.

Let us write $U(t) = U(t,0)$ for
convenience, and let us suppose given
states $\\alpha$ and $\\beta$.
The probability that the system finds
itself in state $\\beta$ after time $t$
is given by the matrix element

$$
\\bra \\beta U(t)  \\ket \\alpha
$$

This is just the kind of information
we need for comparison with experiment.

The propagator, like the family of state
vectors $\\psi(t)$, satisfies a differential
equation -- essentially a Schroedinger equation
for operators. To find it, differentiate the
equation $\\psi(t) = U(t)\\psi(0)$ to obtain

$$
i\\hbar \\frac{d\\psi}{dt} = i\\hbar \\frac{dU}{dt}\\psi(0)
$$

Substitute (C) to obtain

$$
i\\hbar \\frac{dU}{dt}\\psi(0)  = H\\psi(t)
$$

Applying $\\psi(t) = U(t)\\psi(0)$ again, we find that

$$
i\\hbar \\frac{dU}{dt}\\psi(0) = HU\\psi(0)
$$

If this is to hold for arbitrary $\\psi(0)$, then

$$
\\frac{dU}{dt} = -\\frac{i}{\\hbar}HU
$$

If $H$ does not depend on time, the preceding
ODE has an immediate solution, namely


$$
U(t) = e^{-i(t/\\hbar) H}
$$

Think of $H$ as a big matrix, and of the expression
on the right as a big matrix exponential.


## Notes on the free-particle propagator

Below are graphs of the real part of the
free-particle propagator for time
$t = 1, 2, 4,16$.


![xx::center](http://noteimages.s3.amazonaws.com/jim_images/propagator-t=1-63c8.png)


![xx::centerhttp://noteimages.s3.amazonaws.com/jim_images/propagator-t=2-6feb.png)

![xx::center](http://noteimages.s3.amazonaws.com/jim_images/propagator-t=4-a035.png)

![xx::center](http://noteimages.s3.amazonaws.com/jim_images/propagator-t=16-e5ae.png)

**Jupyter code**

```python
%matplotlib inline

import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 6*np.pi, 500)
t=4
plt.plot(x, np.cos(x**2/t)/np.sqrt(t))
plt.title('Free particle propagator, t=4');
```

"""


changeLog : String
changeLog =
    """
 # Main Issues

- Gutter numbers do not align with true line numbers when there are
very long lines.

- Synchronized scrolling of editor and rendered text windows

- Auto-wrap as text approaches right-hand margin


See the [full list of issues](https://github.com/jxxcarlson/elm-text-editor/issues).
I may need help on some of these.

 ## Fixed

 - Jump when user clicks at end of line (Fixed Jan 14, 2020).  Thanks to
 Martin Stewart and Wolfgang Schuster whose precise error reports
 helped fix this.

 # ChangeLog

 ## January 19, 2020

 - Replace funky slider with real scrolling
 
 ##  January 13, 2020 (version 5.0.0)
 
 - Change **Clear All** command (ctrl-shift-C) to (ctrl-option-C)
 
 - Add feature *Copy editor selection to system clipboard*, attach 
 to keyboard command ctrl-shift-C.

 ## January 12, 2020 (version 4.0.0)

 - Simpler API for embedding edtior

 - Configure app using height of editor window
