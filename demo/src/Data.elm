module Data exposing (about, astro, markdownExample, mathExample)


about =
    """
# About this app

What you see here is a demonstration of
a pure Elm text editor. The app has two
windows.  On the left is the editor
itself.  On the right is the content of
the editor suitably rendered. This
document is written in a [flavor of
Markdown](https://package.elm-lang.org/packages/jxxcarlson/elm-markdown/latest/)
that can handle mathematical
notation, like this:

$$
\\int_0^1 x^n dx = \\frac{1}{n+1}
$$

Documents can also be written in
[MiniLaTeX](https://minilatex.io),
a subset of LaTeX that is designed
to be rendered on the fly to Html.

## Using the editor

Do ctrl-click in the green bar below to
bring up a menu of commands, e.g.,
ctrl-O to open a file and ctrl-option-S
to save the current contents of the
editor to a file.

## Roadmap

This editor is a work in progress.
Version 1.0 will be announced when it is
ready. I appreciate feedback and bug
reports.  The best way is to post an
issue on the [Github
repo](https://github.com/jxxcarlson/elm-ed
itor2). Email to jxxcarlson@gmail.com
also works.

## Acknowledgements

The starting point for this editor was
the code of [Martin Janiczek](https://discourse.elm-lang.org/t/text-editor-done-in-pure-elm/1365). I also
learned a great deal from the work
 of [Sydney Nemzer](https://sidneynemzer.github.io/elm-text-editor/).

## Note

This editor will supersede [the previous version](https://package.elm-lang.org/packages/jxxcarlson/elm-text-editor/latest/).
It has not yet been published on the [Elm package manager](https://package.elm-lang.org), but will be as soon as it reaches
feature parity wth the previous version.


"""


markdownExample : String
markdownExample =
    """
# Markdown Demo

The Markdown in this window is rendered using the Elm package
[jxxcarlson/elm-markdown](https://github.com/jxxcarlson/elm-markdown). Below we illustrate some typical Markdown
elements: images, links, headings, etc.

![Hummingbird](http://noteimages.s3.amazonaws.com/jxxcarlson/hummingbird2.jpg)
Hummingbird (Meditation)

Link: [New York Times](http://nytimes.com)

Text styles: **bold** *italic* ~~strike it out~~



## Code

He said that `a := 0` is an initialization
statement.

```python
# Partial sum of the harmonic series:

sum = 0
for n in range(1..100):
  sum = sum + 1.0/n
sum
```

## Verbatim and Tables (Extensions)

A verbatim block begins and ends
with four tick marks. It is just
like a code block, except that there is no
syntax highlighting.  Verbatim blocks
are an extension of normal Markdown.

````
Verbatim text has many uses:

   Element    |    Z
   --------------------
   Altium     |    4/5
   Brazilium  |    7/5
   Certium    |    9/5
````

But better is to use Markdown tables:

|  Element  | Symbol |  Z | A |
| Hydrogen  | H      |  1 | 1.008   |
| Helium    | He     |  2 |  4.0026 |
| Lithium   | Li     |  3 |  6.94   |
| Beryllium | Be     |  4 |  9.0122 |
| Boron     | B      |  5 | 10.81   |
| Carbon    | C      |  6 | 12.011  |
| Nitrogen  | N      |  7 | 14.007  |
| Oxygen    | O      |  8 | 15.999  |
| Flourine  | F      |  9 | 18.998  |
| Neon      | Ne     | 10 | 20.180  |


## Lists

Indent by four spaces for each level.  List items
are separated by blank lines.

- Solids

    - Iron *(metal)*

        - Iron disulfide (Pyrite): $FeS_2$, crystalline

        - Iron(II) sulfed $FeS$, not stable, amorphous

    - Selenium *(use for solar cells)*

- Liquids

    - Alcohol *(careful!)*

    - Water *(Ok to drink)*


## Quotations


Quotations are offset:

> Four score and seven years ago our
fathers brought forth on this continent,
a new nation, conceived in Liberty,
and dedicated to the proposition
that all men are created equal.

> Now we are engaged in a great c
ivil war, testing whether that
nation, or any nation so
conceived and so dedicated,
can long endure. We are met o
In a great battle-field of that war.
We have come to dedicate a portion
of that field, as a final resting
place for those who here gave their
lives that that nation might live.
It is altogether fitting and proper
that we should do this.

> But, in a larger sense, we can not
dedicate — we can not consecrate —
we can not hallow—this ground. The brave men,
living and dead, who struggled here,
have consecrated it, far above our poor
power to add or detract. The world will
little note, nor long remember what we say
here, but it can never forget what they d
id here. It is for us the living, rather,
to be dedicated here to the unfinished
work which they who fought here have thus
far so nobly advanced. It is rather for
us to be here dedicated to the great task
remaining before us—that from these
honored dead we take increased devotion
to that cause for which they gave the
last full measure of devotion—that we
here highly resolve that these dead
shall not have died in vain—that
this nation, under God, shall have
a new birth of freedom—and that
government of the people, by the people,
for the people, shall not perish
from the earth.

— Abraham Lincoln, *Gettysbug Address*

## Poetry (Extension)

Poetry blocks, an extension of normal Markdown,
 begin with ">>"; line endings are respected.

>> Twas brillig, and the slithy toves
Did gyre and gimble in the wabe:
All mimsy were the borogoves,
And the mome raths outgrabe.

>> Beware the Jabberwock, my son!
The jaws that bite, the claws that catch!
Beware the Jubjub bird, and shun
The frumious Bandersnatch!


Etcetera!

___


NOTE: this Markdown implementation is
an option for writing documents on
[knode.io](https://knode.io).
Knode also offers MiniLaTeX,
a web-friendly subset of TeX/LaTex.
To see how it works without a sign-in, please
see [demo.minilatex.app](https://demo.minilatex.app).


___

## Installation


To compile, use

```elm
elm make --output=Main.js
```

Then open `index.html` to run the app.


"""


mathExample =
    """
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


astro =
    """
# Greek Period ___

[Main](#id/0089c6c9-aa54-4c42-8844-c821d2684c9c)

___

## Motion of the Sun (DRAFT)



FIGURE. Greek astronomy was fundamentally different from that of the
Babylonian scribes, having as its basis geometric models rather than
abstract predictive functions. Notable was the 
work of [Hipparchus](https://en.wikipedia.org/wiki/Hipparchus)(c.
190 – c. 120 BCE), who based his astronomy on
the circle. Let us consider just one case, that of the
sun. To understand the problem, let's think about what we can observe.
The first and most obvious fact is that each
day the sun rises let us see what happens. this
is a little slow.

Now for the second fact. If we observe
the sun just before it rises, we can
make out the outline of one of the
twelve constellations of the zodiac:

````
  Constellation  Month    Longitude
  ---------------------------------
    Aries        March        0
    Taurus       April       30  
    Gemini       May         60
    Cancer       June        90
    Leo          July       120
    Virgo        August     150
    Libra        September  180
    Scorpio      October    210
    Sagittarius  November   240
    Capricornus  December   270
    Aquarius     January    300
    Pisces       February   330
````


These constellations form a kind of
belt in the sky, the center of which is
a great circle called the *ecliptic*.
If we observe the sun in March we find
it in the constellation of Aries. The
next month we find it in Taurus, the
month after that in Gemini, etc. Thus,
in addition to its daily motion from
sunrise to sunset, the sun also appears
to move much more slowly through the
constellations of the zodiac. Since
there are 360 degrees in a circle, each
of the constellations occupies an arc
of about 30 degrees along the ecliptic.
Thus we can think of the signs of the
zodiac as marking off 30 degree arcs
along the ecliptic, with the precise
position given in degrees from "the
first point of Aries." This quantity
is the *ecliptic longitude*. As an
example, on March 21 of 2019, at 4:00
GMT, almost exactly at the moment of
the Spring Equinox, the sun was at
longitude 359.991 degrees, or what
is te same thing, -0.009 degrees. One
day later at the same time it was at
longitude 0.984 degrees, and a day
after that at 1.976 degrees.

In ancient times, when there were no
precision optical instruments, the
zodiac gave a crude way of measuring
angular position and had the added
benefit of providing a calendar, in
which the twelve signs are correlated
with the twelve months. In any case, in
Hipparcus time, the notion of ecliptic
longitude was well known. Thus we can
make statements such as "today, the
sun is in Scorpio; its longitude is
231 degrees."

## Uniform Motion

Thi 

Hipparchus' goal was to be able to
compute the eclipitic longitude of the
sun as a function of time. The simplest
model is the one you see in the figure
below. It consists of a circle of some
radius R with the Earth G as center.
The sun moves uniformly around the
circle making one complete turn of 360
degree in 365.25 days. Thereore its
angular velocity is

$$
\\omega = \\frac{360}{365.25} = 0.9856 \\text{ degrees/day}
$$

Note the reasonably close agreement
with the positions of the sun mentioned
above: starting from March 21, 2019
at 4:00 and advancing in 24 hour
increments, we have the following table
for one week of the Sun's position.
An entry in the last column is the
current longitude minus the previous
day's longitude.

````
Date               Long.   Diff
-------------------------------
March 21, 2019    -0.009
March 22, 2019     0.984  0.993
March 23, 2019     1.977  0.992
March 24, 2019     2.968  0.991  
March 25, 2019     3.959  0.991  
March 26, 2019     4.950  0.991 
March 27, 2019     5.940  0.990
-------------------------------
````

Given this model, we can make various predictions.
'For example, using the [Ecliptic Longitude Tables](https://www.imo.net/resources/solar-longitude-tables/), we
find that $\\theta = 280.001$ on January 1,
2018, that $\\theta = 311.561$ on Febraury 1.

$$
\\theta = 280.001 + \\omega T = 310.55 \\text{ degrees}
$$

The actual longitude is 1.006 degrees
greater. What is wrong?

FIGURE

## Non-uniform Motion

The discrepancy we have just seen was
well known to Hipparchus, who realized
that the apparent motion of the sun
as seen from the Earth, while it may
be along a circle, is not uniform. The
observational data of the time, even
though much less accurate than what
we have today, was good enough to show
that the simple model is too simple.
Hipparchus' solution is shown in the
next figure. The sun moves uniformly
around a circle of radius $R$ centered
at $O$, but the Earth is located
off-center at $G$, some $d$ units away.
The point $\\Pi$ is the *perigree*, the
point at which the sun is closest to
Earth. The point $A$ is the *apogee*,
the point at which the sun is farthest
from Earth.

Let us now compare the motion of the
Sun as seen from Earth as it moves
from $Pi$ to $L$ with its motion from
$M$ to $A$. The figure is set up so
that $\\angle \\Pi OL = \\angle MOA$.
Therefore, assuming uniform motion
with center $O$, the time taken from
$\\Pi$ to $L$ is the same as the time
taken from $M$ to $A$. Now conside
the apparent motion as viewed from the
Earth at $G$. The angle $\\angle MGA$
is greater than the angle $\\angle \\Pi
G L$. Therefore the sun appears to move
faster from $\\Pi$ to $L$ than it does
from $M$ to $A$. Consequently Hipparchus'
model gives the correct qualitative
results: faster motion near perigee
and slower apogee, when it is further
away.

FIGURE

Hipparchus' model also yields a
quantitative formula for the rate of
change of the ecliptic longitude. While
the original arguments were based on
geometry and an early versifon of
trigonometry, we shall use modern
trigonometry and a bit of calculus.
To state the result, let $\\omega$ be
the angular velocity of the sun. This
is the same as the rate of change in
the ecliptic longitude of the sun,
which is given by $\\phi = \\angle \\Pi
GL$. Let $\\bar \\omega$ be the mean
angular velocity. This is the rate of
change in the angle $\\theta = \\angle
\\Pi O L$, which is $0.9857 \\text{
degrees/day}$. Now consider the ratio
$k$ of the angular velocity to the
mean angular velocity. This quantiy
depends on $\\theta$, as does $\\omega$.
Thefore we can write

$$
\\omega(\\theta) = k(\\theta)\\bar \\omega,
$$

We will show that $k(\\theta)$ satisfies
the inequality

$$
1 - \\epsilon 
  \\;\\lesssim\\;  k(\\theta) 
  \\;\\lesssim \\;1 + \\epsilon
$$

This is a small quantity, with a value
of about 0.03. The symbol $\\;\\lesssim\\;$
stands for "approximate inequality."
The discrepancy commited by this and
the true, slightly more complicated
inequality is about $\\epsilon^2$. When
$\\epsilon = 0.03$, one has $\\epsilon^2
\\sim 0.0001$.

### Finding the parameters

We can use this inequality to find the
ratio $k = d/R$ using observational
data. From the table XXX of the suns's
motion for 2019, one finds that the
mean angular velocity of the sun ranges
from $0.953$ to $1.02$ degrees per day
with an average of $0.98547$. Using
the maximum, we find that $\\epsilon
\\sim 0.02$. Using the minimum, we
find $\\epsilon = 0.047$. Let's take
$\\epsilon$ to be the average of these
values, $0.0335$. This means that if
we make physical version of Hipparchus'
model with a radius $R$ of one meter,
the Earth will be 3.4 centimeters
off-center.

FIGURE

### Derivation

From the figure, we have

$$
\\tan \\phi = \\frac{R\\sin \\theta}{R \\cos \\theta - d },
$$

so that

$$
\\phi = \\arctan \\frac{R\\sin \\theta}{R \\cos \\theta - d }
$$

Differentiate this equation with
respect to time to obtain

$$
\\frac{d\\phi}{dt}
  = 
\\frac{1 - (d/R)\\cos\\theta}{1 - 2(d/R)\\cos\\theta + (d/R)^2} 
\\frac{d\\theta}{dt}
$$

Set $k = d/R$ and rewrite the above
to obtain

$$
\\frac{d\\phi}{dt} 
  =
\\frac{1 - k\\cos\\theta}{1 - 2k\\cos\\theta + k^2} \\frac{d\\theta}{dt}
$$

Then

$$
\\frac{d\\phi}{dt}
  = k(\\theta)\\frac{d\\theta}{dt}
$$

with

$$
k(\\theta) = \\frac{1 - 2k\\cos\\theta + k^2}{1 - k\\cos\\theta}
$$

One finds that

$$
k(0) = \\frac{1}{1-k} \\sim 1 + k
$$

and

$$
k(180) = \\frac{1}{1 + k} \\sim 1 - k
$$

These are the minimum and maximum
values, repectively

### Approximations

The formula for the geometric series is

$$
\\frac{1}{1 - q} = 1 + q + q^2 + q^3 + \\cdots,
$$

where $|q| < 1$. If we ignore terms
of order two and higher in $q$ we have
the approximation

$$
\\frac{1}{1-q} \\sim 1 + q,
$$

Let's see how good this approximation
is for $q = 0.03$. In that case,

$$
\\frac{1}{1 - 0.03} = 1 + 0.03 + 0.0009 + 0.0000027 + \\ldots
$$

so

$$
\\frac{1}{1 - 0.03} \\sim 1.03,
$$

with an error of at most $0.00091$.
For the same reason, we have the estimate

$$
1 - \\epsilon \\le k(\\theta) \\le 1 + \\epsilon
$$

## Epicycles

![Epicycles::left](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBFgKMx3RF55RDSrFnSlm78yiO4dL1rvxRjKZ2IYq6QhzYtVlXcg) In the second model, the Earth is at
the center of of the large circle. However,
the moon moves not on that circle, but
rather on a secondary circle attached to it.
To get numbers of out of these models, one
needs both geometry and trigonometry.
Hipparchus had what amounted to trig tables, but
for the chord function, not the sine.
Referring to the figure below,

$$
\\text{chord } \\angle AOC = \\frac{AC}{AO}
$$

whereas

$$
\\sin\\angle AOB = \\frac{AB}{AO}
$$

FIGURE

One of the criticisms of Greek astronomy
is that neither the equant nor the
epicycles are real, much less the
celestial sphere. This is certainly
so. However, it is worth noting that
Claudius Ptolelemy (100–170 CE) gave
proof in his book,the *Almagest*, that
the two models were equivalent. For
this reason, I believe it is doubtful
that they took these models to be much
more than a computational device.

![epicylcle::left](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQYfJQQeoGYhF8EKjHn1AOvfetlYQHhFqbiK0uhOJvDmxzyc7mk8Q)

With the epicycle model, one could
explain a heretefore puzzling
phenomenon as well as make more accurate
predictions. Planets, like the sun and
moon, rise in the East after sunset,
moving slowly towards the West, where
they later set. But there is a second
motion superimposed on this daily one.
If you look up in the sky at the same
hour every night, you will notice that
the planets Mars, Jupiter, and Saturn
will be a little further East each
day. This motion, very roughly, is
explainable by the single-circle
model. Not the variations in speed,
but certainly the average speed. One
planet, however behaves differently.
This is Mars. From to time its slower
eastward motion slows, comes to a
stop, and reverses direction, moving
westward against the background of the
stars. After a while it resumes its
slow eastward motion. This phenomenon,
known as *retrograde motion*, is
explained by an epiclyclic model where
the smaller circle rotates in the
direction opposite of the big circle's
rotation.

As astronomers made more and more
accurate measurements and kept better
and better records, they noticed that
the one-epicycle model gave predictions
at variance with observation. After much
checking and recalculating, they came
to the conclusion that the observations
were correct and the model was flawed.
Another epicycle was added and its
radius and rate of rotation tuned to
give the best possible result. This
cartoon descriptipon describes the long
process between Ptolemy and Copernicus
during which the Ptolemy's model was
elaborated and made ever more accurate.
Most of this work was carried on in
the Muslim world, with distinguished
scientist-scholars from Persia and
Baghdad to Southern Spain.

## Annotated References

[A Modern Almagest, Robert Fitzpatrick](https://farside.ph.utexas.edu/Books/Syntaxis/Almagest.pdf) This is a
PDF version of Fitzpatrick's book, also available from
Amazon. It gives an account of
Ptolemy's Almagest accessible to the modern reader and
also debunks some of the
standard but uninformed historical

[Eccentrics, Deferents, Epicycles, and Equants](https://www.mathpages.com/home/kmath639/kmath639.htm) An excellent

[Ephemerides of the sun](https://www.imo.net/resources/solar-longitude-tables/solar-longitudes-2019/) Tables of the

[Drawing by epicycles](https://brettcvz.github.io/epicycles/)

[Breakdown of Circular
Paradigm](https://arxiv.org/ftp/physics/papers/0107/0107009.pdf)

[Optimizing Ptolemy](https://arxiv.org/ftp/arxiv/papers/1502/1502.01967.pdf) Reference to

[Summary of Ptolemaic
Astronomy](http://users.clas.ufl.edu/ufhatch/pages/02-TeachingResources/HIS-SCI-STUDY-GUIDE/0034_summaryPtolemiacAstron.html)
"""
