

export const test_tex = `
\\strong{Note.} This version of the MiniLaTeX
demo uses MathJax 3, which is much faster than
the 2.7.* versions and which gives a much better
experience when doing live editing.

\\section{Introduction}

MiniLatex is a subsert
of LaTeX that can
be endered live in the browser using a custom parser.
Mathematical text is rendered by
 \\href{https://mathjax.org}{MathJax}:

$$
\\int_{-\\infty}^\\infty e^{-x^2} dx = \\pi
$$

The combination of MiniLaTeX and MathJax
gives you access to both text-mode
and math-mode LaTeX in the browser.


Feel free to
experiment with MiniLatex using this app
\\mdash you can change the text in the
left-hand window, or clear it and enter
your own text. For more information about
the MiniLaTeX project, please go to
\\href{https://minilatex.io}{minilatex.io},
or write to jxxcarlson at gmail.


An improper integral:

\\begin{equation}
\\label{integral:exp}
\\int_0^\\infty e^{-x} dx = 1
\\end{equation}


\\section{Images}

\\image{http://psurl.s3.amazonaws.com/images/jc/beats-eca1.png}{Figure 1. Two-frequency beats}{width: 350, align: center}

\\section{Lists and Tables}

A list

\\begin{itemize}

\\item This is \\strong{just} a test.

\\item \\italic{And so is this:} $a^2 + b^2 = c^2$

\\item And you can do this:
$ \\frac{1}{1 + \\frac{2}{3}} $

\\end{itemize}


`;

export const quantum_md = `
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

`;
