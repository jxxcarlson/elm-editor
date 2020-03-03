module Data exposing
    ( about
    , aboutMiniLaTeX
    , aboutMiniLaTeX2
    , astro
    , markdownExample
    , mathExample
    , miniLaTeXExample
    )


about =
    """


*NOTE: this app is designed for computers, not phones.*

# About this app

What you see here is a demonstration of
a pure Elm text editor coupled to compilers
for Markdown+Math and MiniLaTeX to produce
an interactive editing environment for
these markup languages.  Files with extention
`.md` and `.latex` can be opened and saved,
MiniLaTeX documents can also be exported
to standard LaTeX.

The app has two
windows.  On the left is the editor
itself.  On the right is the content of
the editor suitably rendered. This
document is written in  [Markdown+Math](
https://package.elm-lang.org/packages/jxxca
rlson/elm-markdown/latest/), a flavor of
Markdown that can handle mathematical
notation. Like this:

$$
\\int_0^1 x^n dx = \\frac{1}{n+1}
$$

Documents can also be written in
[MiniLaTeX](https://minilatex.io),
a subset of LaTeX that is designed
to be rendered on the fly to Html.

## Using the editor

Type ctrl-H (Help) to toggle a list of
editor commands.  Or use the **Help**
button, upper left. Below are a few
examples.


**Sync.** `option-S` will sync the rendered
text with the source text.  To sync the
rendered text to the source text, just
click in the rendered text.  *Coming soon:
the rendered text element will be highlighted.*

**Wrap.** `ctrl-W` will wrap
the current selection, while `ctrl-shift-W`
will wrap the entire document.

**Undo/redo.** If you
make a mistake, use `ctrl-Z` to undo it. If that
was a mistake, use `ctrl-Y` .

**Copy and Paste.**  The commands `ctrl-C` , `ctrl-X` , and
`ctrl-V` are the Editor copy-cut-paste functions.
Use  `ctrl-shift-V` to paste whatever
is in the clipboard into the editor (at the
cursor).  Use `ctrl-shift-C` to copy the
current selection to the system clipboard.
At the moment these two features work only in
Google Chrome

**An Extra.** Use `ctrl-shift-D` to toggle dark mode.
.

## Plans

This editor is a work in progress.
Version 1.0 will be announced when it is
ready. I appreciate feedback and bug
reports.  The best way is to post an
issue on the [Github
repo](https://github.com/jxxcarlson/elm-editor2). Email
to jxxcarlson@gmail.com
also works.

## Acknowledgements

The starting point for this editor was
the code of [Martin Janiczek](https://discourse.elm-lang.org/t/text-editor-done-in-pure-elm/1365). I also
learned a great deal from the work
 of [Sydney Nemzer](https://sidneynemzer.github.io/elm-text-editor/).

## Note

This editor supersedes [the previous version](https://package.elm-lang.org/packages/jxxcarlson/elm-text-editor/latest/).


## On the Horizon

Some of the features below are not pure editor
features; nonetheless, they rely on hooks in the editor,
hence need to be tested in this app.

- ~~Left to right sync for Markown documents~~

- ~~Left
to right sync for MiniLaTex documents~~

- ~~ Right to left sync~~

- ~~Paste system clipboard into editor~~

- ~~Copy editor text to system clipboard~~

- ~~Search and replace~~

- ~~Dark mode option~~

- Highlight rendered text element on sync

- Matching of parentheses, brackets, etc.

- Additional features from Nemzer's editor that
have not yet been implemented.

- Vim mode.  This will take a while to implement.
Now in the meditation phase.


## CHANGELOG

Most recent first

- 2/28/2020. Add ctrl-. (Think >) to go to next search hit

- 2/28/2020. Add ctrl-, (Think <) to go to previous search hit

- 2/28/2020. Add <TAB> to indent by default amount

- 2/28/2020. Add <TAB> to indent by default amount

- 2/28/2020. Add shift-<TAB> to deindent by default amount

- 2/28/2020. Add ctrl-/ for left-to-right sync


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
\\left< \\beta U(t)\\ |\\ \\alpha \\right>
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


aboutMiniLaTeX =
    """



\\title{About MiniLaTeX}
% \\author{James Carlson}
% \\email{jxxcarlson@gmail.com}
% \\date{Feburary 19, 2020}


\\maketitle


\\tableofcontents

\\section{Introduction}

You are looking at demo of an editor coupled to on-the-fly
compilers for Markdown+Math and MiniLaTeX. The first is
a version of Markdown that can handle equations written
in TeX. The second, which we discuss here, is a subset of
LaTeX. As you can see from looking at this source, the
usual ceremony with

\\begin{verbatim}
\\begin{document}

...

\\end{document}
\\end{verbatim}

is not needed.  Just start typing and watch it
being rendered in real time in
the window on the right. To produce a
stand-alone, standard LaTeX file,
press the \\strong{Export} button below. As an
example, compare what you see when you push
the \\strong{L1} button below with the
\\href{http://jxxcarlson.s3.amazonaws.com/anharmonicOscillator.pdf}{PDF version}
obtained by exporting the the document and
running \\code{pdflatex} on it.

\\section{Using this app}

\\highlight{Bear in mind that ths app is a work in
progress}. That said, control-click on the green bar below
to see a list of key commands that you can can use. For
example \\code{ctrl-Z} is undo and \\code{ctrl-Y} is redo,
while \\code{ctrl-shift-S} syncs the rendered text with
the source text: the source text at the cursor is matched
with the corresponding rendered text
.

\\section{Using MiniLaTeX}

The best way to see what you can do with
MiniLaTeX is to look at examples, comparing
the source and rendered text. See documents
\\strong{1}, \\strong{2}, etc. below in the
\\strong{LaTeX Docs} section. See also
the documents at \\href{https://knode.io}{knode.io},
e.g, \\href{https://knode.io/424}{these course notes}.

\\section{Examples}

Here are few examples.  First, an equation:

\\begin{equation}
\\int_{-\\infty}^\\infty e^{-x^2} dx = \\pi
\\end{equation}

Of course, you can use double dollar signs as well.
Second, a theorem environment:

\\begin{theorem} There are are infinitely
many primes $p \\equiv 1 \\ mod\\ 4$.
\\end{theorem}


Third, some code (yes, we need syntax highlighting!)

\\begin{listing}
filterMany : List (a -> Bool) -> List a -> List a
filterMany predicates items =
    let
        makeFilter : (a -> Bool) -> List a -> List a
        makeFilter predicate list =
            List.filter predicate list
    in
    List.foldl makeFilter items predicates
\\end{listing}


Fourth and last, an image grabbed from the web:

\\image{http://noteimages.s3.amazonaws.com/jxxcarlson/hummingbird2.jpg}{Figure 1. Meditation}{width: 350, align: center}

\\section{Plans}

The first order of business is to finish this
demo app, bringing it to the point where it is
useful for writing short documents which can
be exported to standard LaTeX or to a file
of HTML text ready for posting on the web. This means
fixing bugs, adding features, smoothing rough
spots, etc. It will also require some work on the
MiniLaTeX compiler.

The second order of business is integrate this work
into \\href{https://knode.io}{knode.io}, a platform
for creating, editing, and distributing MiniLaTeX
content on the web.

\\section{Feedback, Open Source}

This project is open-source. If you find a bug
or would like to make a feature request, you may
post an issue on the
\\href{https://github.com/jxxcarlson/elm-editor2}{Github Repo}.
You can also contact me via gmail at jxxcarlson.



"""


aboutMiniLaTeX2 =
    """

\\title{Sample MiniLaTeX Doc}
% \\author{James Carlson}
% \\email{jxxcarlson@gmail.com}
% \\date{August 5, 2018}s



\\maketitle

% EXAMPLE 1

\\begin{comment}
This multi-line comment
should also not
be visible in the
rendered text.
\\end{comment}

\\tableofcontents

\\strong{Note.} This version of the MiniLaTeX
demo uses MathJax 3, which is much faster than
the 2.7.* versions and which gives a much better
experience when doing live editing.

\\section{Introduction}

MiniLatex is a subset of LaTeX that can
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



\\italic{Try editing formula
\\eqref{integral:xn} or \\eqref{integral:exp} below.}

The most basic integral:

\\begin{equation}
\\label{integral:xn}
\\int_0^1 x^n dx = \\frac{1}{n+1}
\\end{equation}

An improper integral:

\\begin{equation}
\\label{integral:exp}
\\int_0^\\infty e^{-x} dx = 1
\\end{equation}


\\section{Text-mode Macros}

\\newcommand{\\hello}[1]{Hello \\strong{#1}!}

As illustrated by the examples below,
one can define new text-mode macros
in MiniLaTeX. For example, if we add the text

\\newcommand{\\boss}{Phineas Fogg}

\\begin{verbatim}
\\newcommand{\\boss}{Phineas Fogg}
\\end{verbatim}

then saying

\\begin{verbatim}
\\italic{My boss is \\boss.}
\\end{verbatim}

produces \\italic{My boss is \\boss.}
Likewise, if one says

\\begin{verbatim}
\\newcommand{\\hello}[1]{Hello \\strong{#1}!}
\\end{verbatim}

then the macro
\\backslash{hello}\\texarg{John}
renders as \\hello{John}
For one more example,  make the definition

\\begin{verbatim}
\\newcommand{\\reverseconcat}[3]{#3#2#1}
\\end{verbatim}

\\newcommand{\\reverseconcat}[3]{#3#2#1}

Then \\backslash{reverseconcat}\\texarg{A}\\texarg{B}\\texarg{C} = \\reverseconcat{A}{B}{C}

The macro expansion feature will need a lot
more work and testing.  We also plan to add a
feature so that authors can define new environments.



\\section{MiniLatex Macros}

MiniLatex has a number of macros of
its own,  For example, text can be rendered
in various colors, \\red{such as red}
and \\blue{blue}. Text can \\highlight{be highlighted}
and can \\strike{also be struck}. Here are the macros:

\\begin{verbatim}
\\red
\\blue
\\highlight
\\strike
\\end{verbatim}


\\section{Theorems}

\\begin{theorem}
There are infinitely many prime numbers.
\\end{theorem}

\\begin{theorem}
There are infinitley many prime numbers
$p$ such that $p \\equiv 1\\ mod\\ 4$.
\\end{theorem}

\\section{Images}

\\image{http://psurl.s3.amazonaws.com/images/jc/beats-eca1.png}{Figure 1. Two-frequency beats}{width: 350, align: center}

\\section{Lists and Tables}

A list

\\begin{itemize}

\\item This is \\strong{just} a test.

\\item \\italic{And so is this:} $a^2 + b^2 = c^2$

\\begin{itemize}

\\item Items can be nested

\\item And you can do this:
$ \\frac{1}{1 + \\frac{2}{3}} $

\\end{itemize}

\\end{itemize}

A table

\\begin{indent}
\\strong{Light Elements}
\\begin{tabular}{ l l l l }
Hydrogen & H & 1 & 1.008 \\\\
Helium & He & 2 & 4.003 \\\\
Lithium& Li & 3 & 6.94 \\\\
Beryllium& Be& 4& 9.012 \\\\
\\end{tabular}
\\end{indent}


\\section{Errors and related matters}

Errors, as illustrated below, are rendered in real
time and are reported in red, in place.
For example, suppose the user types the  text

\\begin{verbatim}
  $$
  a^2 + b^2 = c^2
\\end{verbatim}

Then she will see this:

\\image{http://jxxcarlson.s3.amazonaws.com/miniLaTeXErrorMsg-2020-02-22.png}{Fig 2. Error message}{width: 200}


Note, by the way, what happens
when a nonexistent macro like \\italic{hohoho } is used:

\\begin{indent}
\\hohoho{123}
\\end{indent}

This is intentional.  Note also what happens when
we use a nonexistent environment like \\italic{joke}:

\\begin{joke}
Did you hear the one about the mathematician,
the philosopher, and the engineer?
\\end{joke}

This default treatment of unkown environments
 is also intentional, and can even be useful:
 when a document is exported to standard LaTeX,
 the default environment definition can be
 replaced by one of the user's choice.

\\section{Technology}

MiniLatex is written in \\href{http://elm-lang.org}{Elm},
the statically typed functional programming language
created by Evan Czaplicki.  Because of its excellent
\\href{http://package.elm-lang.org/packages/elm-tools/parser/latest}{parser combinator library},
Elm is an ideal choice for a project like the present one.


For an overview of the design of MiniLatex, see
\\href{https://hackernoon.com/towards-latex-in-the-browser-2ff4d94a0c08}{Towards Latex in the Browser}.
Briefly, \\href{https://www.mathjax.org/}{MathJax}
is used inside dollar signs, and Elm is used outside.

\\bigskip


\\section{References}

\\begin{thebibliography}

\\bibitem{D} \\href{https://ocw.mit.edu/courses/physics/8-05-quantum-physics-ii-fall-2013/lecture-notes/MIT8_05F13_Chap_04.pdf}{On Dirac's bra-ket notation}, MIT Courseware.

\\bibitem{G} James Carlson, \\href{https://knode.io/628}{MiniLaTeX Grammar},

\\bibitem{H} James Carlson, \\href{https://hackernoon.com/towards-latex-in-the-browser-2ff4d94a0c08}{Towards LaTeX in the Browser }, Hackernoon

\\bibitem{S} \\href{http://package.elm-lang.org/packages/jxxcarlson/minilatex/latest}{Source code}

\\bibitem{T} James Carlson, \\href{https://knode.io/525}{MiniLatex Technical Report}

\\end{thebibliography}
"""


miniLaTeXExample =
    """
\\setcounter{section}{6}

\\section{Anharmonic Oscillator}

\\innertableofcontents

The classical anharmonic oscillator is one
with a "non-linear spring". By this we mean
that the standard force law $F = -kx$ has
additional terms, e.g., $F = -kx - \\ell x^3$
. In this case the corresponding potential is
a quartic:

\\begin{equation}
V(x) = (1/2)kx^2 + (\\ell/4)x^4
\\end{equation}

In this section we study the quantum anharmonic
oscillator with a quartic term in the
potential. Our first task is to find the
energy of the ground state when a small quartic
term is added to the potential. For this
we need some basic perturbation theory. An
approximation to the ground state energy in
two ways: (i) by doing a Gaussian integral
(ii) by working out the expression $(a +
a^\\dagger)^4$ as a noncommutative polynomial
using the harmonic oscillator operator calculus.

\\subsection{Perturbation theory}

Let us suppose given a quantum mechanical
system with Hamiltonian of the form $H =
H_0 + \\epsilon V$ , where a complete set of
non-degenerate eigenstates for $H_0$ is known.
Let us call these states $\\psi^{(m)}$ . By
nondegenerate, we mean that all eigenspaces
have dimension one. The second term is a small
multiple of an operator which we generally take
to be a potential. We use this setup to find
solutions of the time-ndependent Schroedinger
equation $H\\psi = E\\psi$ up to terms of order
epsilon, where we imagine that true solutions
have an expansion $\\psi = \\psi_0 + \\epsilon
\\psi_1 + \\epsilon^2 \\psi_2 + \\cdots$ .
Substituting into the Schroedinger equation
and ignoring terms in $\\epsilon^2$ or higher
powers, we have

\\begin{equation}
H_0\\psi_0 + \\epsilon H_0 \\psi_1 + \\epsilon V\\psi_0
E_0\\psi_0 + \\epsilon E_0 \\psi_1 + \\epsilon E_1 \\psi_0
\\end{equation}

The $\\epsilon^0$ component of this equation is

\\begin{equation}
H_0\\psi_0 =
E_0\\psi_0
\\end{equation}

Therefore $\\psi_0$ , the zeroth term in the
perturbation expansion, is an eigenfunction of
the unperturbed Hamiltonian. That is, $\\psi_0
= \\psi^{(m)}$ up to a constant.

The $\\epsilon^1$ component of the equation reads

\\begin{equation}
\\label{foperturbationequation}
 H_0 \\psi_1 + V\\psi_0
 =
 E_0 \\psi_1 +  E_1 \\psi_0
\\end{equation}

Take the inner product with $\\psi_0$ :

\\begin{equation}
\\left< \\psi_0 | H_0  | \\psi_1\\right> +  \\left< \\psi_0  | V | \\psi_0 \\right> \\
 = \\
 E_0 \\left< \\psi_0  |  \\psi_1 \\right> +  E_1 \\left< \\psi_0  |  \\psi_0 \\right>
\\end{equation}

Because $\\psi_0$ is an eigenfunction of $H_0$
, the first term on the left is equal to the
first term on the right, so that

\\begin{equation}
\\label{perturbation_of_energy}
E_1 =\\frac{\\left<\\psi_0 | V | \\psi_0 \\right>}{ ||\\psi_0||^2 }
\\end{equation}

In other words, if $E^{(m)}$ is the energy of
the unperturbed Hamiltonian, then the energy
of the corresponding state of the perturbed
system is $E^{(m)} + \\epsilon \\Delta E^{(m)}$
, where

\\begin{equation}
\\label{perturbation_of_En}
\\Delta E^{(m)} =\\frac{\\left<\\psi^{(m)} | V | \\psi^{(m)} \\right>}{ || \\psi^{(m)} ||^2 }
\\end{equation}

To find the wave functions for the perturbed
system, assume that $\\psi_0 = \\psi^{(n)}$
and take the inner product of
\\eqref{foperturbationequation} with
$\\psi^{(m)}$ for $m \\ne n$ . One obtains

\\begin{equation}
\\left< \\psi^{(m)} | H_0 | \\psi_1 \\right> + \\left< \\psi^{(m)} | V | \\psi_0 \\right>
  =
E_0\\left< \\psi^{(m)} | \\psi_1 \\right> + E_1\\left< \\psi^{(m)} | \\psi_0 \\right>
\\end{equation}

The first term on the left is $E_m\\left<
\\psi^{(m)} | \\psi_1 \\right>$ and the last term
on the right vanishes, so that we obtain

\\begin{equation}
\\label{perturbation_fourier_coefficients}
  \\left< \\psi^{(m)} | \\psi_1 \\right>
  = \\frac{\\left< \\psi^{(m)} | V | \\psi_1 \\right>}{E_0 - E_m}
\\end{equation}

The numbers are the Fourier coefficients of
the expansion of $\\psi$ :

\\begin{equation}
\\label{perturbation_fourier_expansion}
  \\psi = \\psi^{(n)}
+ \\epsilon \\sum_{m \\ne n} \\frac{\\left< \\psi^{(n)} | V | \\psi^{(m)} \\right>}{  E^{(n)} - E^{(m)}  }\\psi^{(m)}
\\end{equation}

\\subsection{Quartic perturbation by Gaussian
integrals}

Let us consider a quartic perturbation of the
harmonic oscillator, where

\\begin{equation}
H_0 = \\frac{1}{2m}(\\hat p^2 + m^2 \\omega^2 x^2) +  \\lambda g x^4,
\\end{equation}

where $\\lambda$ is a small dimensionless
parameter. Now $p^2/2m$ is a kinetic energy
term, so $[gx^4] = [E]$ , where $E$ is an
energy and $[\\ ]$ means "units of". Solving,
we have $[g] = [Ex^{-4}]$ . Let us try to cook
up a "natural value" for $g$ . A natural energy
is the zero point energy of the oscillator,
$\\omega\\hbar/2$ . In addition, we need a
natural length scale for $x$ . To this end,
consider the ground state wave function, which
is proportional to $e^{-m\\omega x^2/2\\hbar}$
. Solve for $m\\omega x^2/2\\hbar = 1$ . One
obtains $x_0^2 = 2\\hbar/m\\omega$ . At disance
$x = x_0$ , the value of the wave function
has decreased from its maximum at $x = 0$ by
a factor of $1/e$ . Thus a natural choice is

\\begin{equation}
g = \\frac{\\omega\\hbar}{2}\\left(\\frac{2\\hbar}{m\\omega}\\right)^{-2} = \\frac{m^2 \\omega^3}{8\\hbar}
\\end{equation}

Writing $H= H_0 + \\lambda g x^4$ , we find
ourselves in the context of perturbation
theory. Then the shift in the $n$ -th energy
level is given by

\\begin{equation}
\\label{DeltaEn]}
\\Delta E_n = \\lambda g \\left< \\psi_n | x^4 | \\psi_n \\right> ,
\\end{equation}

and where the $\\psi_n$ are normalized wave
functions for the harmonic oscillator.
Referring to the definition of the normalized
ground state wave function, we find that the
shift in energy levels is given by a Gaussian
integral:

\\begin{equation}
\\Delta E_0 = \\lambda g \\left(\\frac{m\\omega}{\\pi\\hbar}\\right)^{ 1/2 } \\int_{-\\infty}^\\infty x^4 e^{-m\\omega x^2 / \\hbar} dx
\\end{equation}

The integral to be evaluated has the form

\\begin{equation}
I_2 = \\int_{-\\infty}^\\infty x^2 e^{-\\alpha x^2} dx
\\end{equation}

To compute it, recall that

\\begin{equation}
\\int_{-\\infty}^\\infty e^{-\\alpha x^2} dx
= \\left( \\frac{\\pi}{\\alpha} \\right)^{1/2}
\\end{equation}

Now compare this derivative computation

\\begin{equation}
\\frac{d}{d\\alpha} \\int_{-\\infty}^\\infty e^{-\\alpha x^2} dx = - \\int_{-\\infty}^\\infty x^2 e^{-\\alpha x^2} dx
\\end{equation}

with this one:

\\begin{equation}
\\frac{d}{d\\alpha} \\left(\\frac{\\pi}{\\alpha}\\right)^{1/2} = -\\frac{1}{2}\\left(\\frac{\\pi}{ \\alpha^3 } \\right)^{1/2}
\\end{equation}

to conclude that

\\begin{equation}
\\int_{-\\infty}^\\infty x^2 e^{-\\alpha x^2} dx =  \\frac{1}{2}\\left(\\frac{\\pi}{ \\alpha^3 } \\right)^{1/2}
\\end{equation}

Similarly, one obtains

\\begin{equation}
\\int_{-\\infty}^\\infty x^4 e^{-\\alpha x^2} dx =  \\frac{3}{4}\\left(\\frac{\\pi}{ \\alpha^5 } \\right)^{1/2}
\\end{equation}

Working through the constants, one obtains at
long last the first order energy shift:

\\begin{equation}
\\label{anharmonic_correction}
\\Delta E_0 = \\frac{3}{16}\\,\\left( \\frac{\\omega \\hbar}{2}\\right)  \\lambda
\\end{equation}

\\subsection{Quartic perturbation by operator
calculus}

The operator "multiplication by $x$ " can
also be written in terms of creation and
annihilation operators. Adding the expressions
for these operators in the xref::225[last
section], we find that

\\begin{equation}
x = \\left(\\frac{ \\hbar }{  2m \\omega} \\right)^{1/2} (a + a^\\dagger )
\\end{equation}

Substituting this into (<<DeltaEn>>), we find
that

\\begin{align}
\\label{aa4}
\\Delta E_0 &= \\lambda g \\left(\\frac{ \\hbar }{  2m \\omega} \\right)^{2} \\left< \\psi_0 | ( a + a^\\dagger )^4 | \\psi_0 \\right> \\\\
&= \\lambda \\frac{1}{16}\\,\\frac{\\omega \\hbar}{2}\\,\\left< \\psi_0 | ( a + a^\\dagger )^4 | \\psi_0 \\right>
\\end{align}

The operator $(a + a^\\dagger)^4$ is a sum of
sixteen noncommutative monomials which can be
listed in lexicographical order as

\\begin{align}
& a^\\dagger a^\\dagger a^\\dagger a^\\dagger \\\\
& a^\\dagger a^\\dagger a^\\dagger a \\\\
& a^\\dagger a^\\dagger a  a^\\dagger \\\\
& a^\\dagger  a  a^\\dagger a^\\dagger \\\\
& etc
\\end{align}

We say that a monomial is in \\term{normal
order} if all of the creation operators appear
before the annihilation operators. In the list
above, the first, second, and fourth entries
are in normal order. Using the identity
$[a,a^\\dagger] = 1$ , any monomial can be
expressed as a sum of monomials in normal
order. One has, for instance, $aa^\\dagger =
a^\\dagger a + 1$ . Now consider the monomials
$M$ that might enter into the formula (<<aa4>>)
with nonzero coefficient. A bit of reflection
tells us that such a monomial must consist of
two creation operators and two annihilation
operators. This is because the expression
$M\\psi_0$ must be be a multiple of $\\psi_0$ .
That is, $M$ must raise the eigenvalue twice
and also lower it twice. There are six such
monomials. The monomial $M$ must also have a
creation operator on the right, since otherwise
$M\\psi_0 = 0$ . For essentially the same
reasons, it must have an annihilation operator
on the left. This constraint reduces the number
of admissible monomials to two: $aa^\\dagger
aa^\\dagger$ and $aaa^\\dagger a^\\dagger$ . Let
us give the beginning of the computation for
the first of these so that you see the pattern.
Then we will state the result. The computation
is a kind of game in which we move $a$ 's to
the right using the relation $ a a^\\dagger
= a^\\dagger a + 1$ . To win the game is to
express the monomial as a sum of monomials in
normal order. The first move is $aaa^\\dagger
a^\\dagger = aa^\\dagger a a^\\dagger +
aa^\\dagger$ . After a sequence of such moves,
you will find that

\\begin{equation}
aaa^\\dagger a^\\dagger = a^\\dagger a^\\dagger  aa + 4a^\\dagger a + 2
\\end{equation}

For the second monomial, you will find that

\\begin{equation}
aa^\\dagger a a^\\dagger =  a^\\dagger a^\\dagger  aa + 2a^\\dagger a + 1
\\end{equation}

We are led to the conclusion that

\\begin{equation}
(a + a^\\dagger )^4 = M' + 3,
\\end{equation}

where $M'$ is a sum of monomials different from
1. Now think about expressions $\\left< \\psi_0 |
M | \\psi_0 \\right>$ , where $M$ is a monomial in
normal order. It is zero if $M \\ne 1$ and is
1 if $M = 1$ . We can therefore read off the
value of the perturbation term for the energy:

\\begin{equation}
\\Delta E_0 = \\frac{3}{16}\\,\\left( \\frac{\\omega \\hbar}{2}\\right)  \\lambda
\\end{equation}

This is in agreement with the value computed
by doing a Gaussian integral.

\\begin{remark}
Let   $P(a,a^\\dagger)$  be  a  polynomial  in  the  creation  and  annihilation  operators.   Let   $m_M(P)$  be  the  multiplicity  with  which   $M$  appears  in  the  normal  order  expression  for   $P$ .  Then   $\\left< \\psi_0 | P(a,a^\\dagger) | \\psi_0 \\right> = m_1(P)$
\\end{remark}

Note the combinatorial flavor of the
computation of the energy shift by this method.
We will encounter it again in the theory of
Feynman diagrams.

\\subsection{References}

\\href{http://www2.ph.ed.ac.uk/~ldeldebb/docs/QM/lect17.pdf}{Perturbation Theory, Edinburgh}

\\href{http://www.cavendishscience.org/phys/tyoung/tyoung.htm}{Two-slit experiment}
"""
