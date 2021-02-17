module Text exposing (..)

import Dict


textDictionary =
    Dict.fromList [ ( "start.tex", start ), ( "markdown.md", markdownDemo ) ]


numbered : String -> String
numbered str =
    str
        |> String.lines
        |> List.indexedMap (\k s -> String.padLeft 4 ' ' (String.fromInt k ++ ": " ++ s))
        |> String.join "\n"


hello =
    "Hello, it is me you're looking for!"


plansAndChangeLog =
    """
"""


test2 =
    """AAA
BBB
CCC
DEF
GGG
HHH
"""


markdownDemo =
    """
# A Pure Elm Markdown Parser


## Introduction

![Hummingbird::left](http://noteimages.s3.amazonaws.com/jxxcarlson/hummingbird2.jpg) 


  This project grew out of the need to have a pure Elm Markdown
 parser-renderer that could also handle mathematical
 text.  Mathematical text is rendered by
 MathJax 3, which has very large performance advantages
 compared to its predecessors.
 The Markdown used here offers three options: *Standard*,
 *Extended* and *ExtendedMath*. The Extended option provides for strike-through
 text, verbatim blocks, poetry blocks, and tables.  ExtendedMath
 handles
 formulas written in TeX/LaTeX:

$$
\\int_{-\\infty}^\\infty e^{-x^2} dx = \\pi
$$

Note also that there is an automatically generated
active table of contents. It can be placed inside the document
at the top, to one side, as it is here, or it can be absent.


The [library](https://package.elm-lang.org/packages/jxxcarlson/elm-markdown/latest/)
 with which this demo app is built is suitable for
light-weight writing tasks that require
mathematical notation — problem sets, short class notes, etc.


This project is a work in progress: more to to do make
it adhere as closely as possible to the CommonMark spec.
Write me at jxxcarlson@gmail.com with comments and bug reports,
or post an issue on the [GitHub repo](https://github.com/jxxcarlson/elm-markdown).

For installation, see the notes
at the end. This Markdown package is written in pure Elm.
It uses MathJax.js to render math formulas.

Below we illustrate some typical Markdown elements: images, links, headings, etc.


Link: [New York Times](http://nytimes.com)

Text styles: **bold** *italic* ~~strike it out~~


## Inline Math

This is a test: $a^2 + b^2 = c^2$.

## Display Math

So is this:

$$
\\int_0^1 x^n dx = \\frac{1}{n+1}
$$


## Code

He said that `a := 0` is an initialization statement.


```python
sum = 0
for n in range(1..100):
  sum = sum + 1.0/n
sum
```

## SVG

Use an `@@svg` block to render SVG.

@@svg
<svg width="100" height="100">
<circle cx="50" cy="50" r="40" 
stroke="blue" stroke-width="3" fill="cyan" />
</svg>

Here is the source text:

```nolang
@@svg
<svg width="100" height="100">
<circle cx="50" cy="50" r="40"
stroke="blue" stroke-width="3" fill="cyan" />
</svg>
```

## Verbatim and Tables

A verbatim block begins and ends with four tick marks.
It is just like a code block, except that there is no
syntax highlighting.  Verbatim blocks are an extension
of normal Markdown.

````
Verbatim text has many uses:

   Element    |    Z
   --------------------
   Altium     |    4/5
   Brazilium  |    7/5
   Certium    |    9/5
````

But better here is to use Markdown tables:

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

## Numbered lists

You can use math inside a numbered list

**Problem Set 19A**

4. Show that $u(x,t) = f(x - ct)$ is a solution to the equation $\\partial u(x,t)/\\partial x + c^{-1} \\partial u(x,t)/\\partial t = 0$.

3. State the wave equation and show that $u(x,t)$ as above is a solution to it.

2. In what direction does the wave defined by $u(x,t) = f(x - ct)$ move?

4.  Find a solution of the wave equation that represents a pulse moving in the opposite direction.



## Quotations


Quotations are offset:


> Four score and seven years ago our fathers brought
forth on this continent, a new nation, conceived in
Liberty, and dedicated to the proposition that all
men are created equal.

> Now we are engaged in a great civil war, testing
whether that nation, or any nation so conceived and
so dedicated, can long endure. We are met on a great
battle-field of that war. We have come to dedicate a
portion of that field, as a final resting place for
those who here gave their lives that that nation might
live. It is altogether fitting and proper that we
should do this.

> But, in a larger sense, we can not dedicate—we can
not consecrate—we can not hallow—this ground. The
brave men, living and dead, who struggled here, have
consecrated it, far above our poor power to add or
detract. The world will little note, nor long remember
what we say here, but it can never forget what they did
here. It is for us the living, rather, to be dedicated
here to the unfinished work which they who fought here
have thus far so nobly advanced. It is rather for us
to be here dedicated to the great task remaining before
us—that from these honored dead we take increased
devotion to that cause for which they gave the last
full measure of devotion—that we here highly resolve
that these dead shall not have died in vain—that
this nation, under God, shall have a new birth of
freedom—and that government of the people, by the
people, for the people, shall not perish from the earth.

— Abraham Lincoln, *Gettysbug Address*

## Poetry (Extension)

Poetry blocks, an extension of normal Markdown,
id implemented as a code block with language
*verse*.

```verse
Twas brillig, and the slithy toves
Did gyre and gimble in the wabe:
All mimsy were the borogoves,
And the mome raths outgrabe.

Beware the Jabberwock, my son!
The jaws that bite, the claws that catch!
Beware the Jubjub bird, and shun
The frumious Bandersnatch!
```


Etcetera!

___

## Installation


To compile, use

```elm
elm make --output=Main.js
```

Then open `index.html` to run the app.


"""


start =
    """

\\title{Towards a LaTeX IDE for the Web}

\\maketitle

\\tableofcontents

This app is a work-in-progress demonstration of the
pure Elm text editor that I have been working on for
a while. Although more work is needed, it can
already do some useful thing: documents can be
written in MiniLaTeX (a subset/variant of LaTeX),
MathMarkdown (a flavor of Markdown that can render
LaTeX-style formulas), and plain text.

$$
\\int_{-\\infty}^\\infty e^{-x^2} dx = \\pi
$$

When the editor is in good shape, it will become
part of
\\href{https://minilatex.lamdera.app}{minilatex.lamdera.app}.
I hope that it will find other uses as well.

\\section{Command execution}

One new feature of note is \\blue{command
execution}.
As an example, try this: type ESC, then
"th", then ESC again. You should see a dummy theorem
environment in the source text. Replace the "XXX"
that you see with whatever you like.

Other things to try with ESC are \\code{eq}, a dollar
or double dollar sign, as well as \\code{enum} and
\\code{item}. I'll be adding other environments as I
continue to work on the app. Also, if you would like
to experiment, press ctrl-option-C to clear the editor
and rendered text. Then have at it!


\\section{Other features}

\\strong{New documents.} Use the \\blue{New document} button in the footer
to create a new document. In the popup window,
you can choose the document format


\\strong{Files.} Files on disk can be opened, edited.


\\strong{Footer.} Note the other buttons in the footer:
Open, Export, Save, and PDF: \\italic{open
files on disk, export
MiniLaTeX files to standard LaTeX, save as MiniLaTeX,
and generate PDF.} (Try the PDF button now).


\\strong{Demo files.} Note the buttons in the footer
on the extreme right. Clicking on them will load a file
into the editor.  As a bonus, the app can render
Markdown docs (along with LaTeX-style formulas).

\\strong{More info.} For more info, press the \\blue{Help} button in the
header.  Do note the various key commands.  They
work OK for Mac users, but I need to have an
alternative keymap for Linux and Windows users.
Suggestions are hereby solicited!

\\section{Known bugs}

Lists in LaTeX are not always rendered properly.
An artefact of the way text is stored ... I'm
woking on it.

\\section{Feedback}

Writing an editor is a complex undertaking.  I need
feedback on what doesn't work and what is missing.
Please see my contact info below.  Posting issues
on Github is welcome, but Slack, Email, and Twitter
also work.

\\section{Contact}

Do contact me if you have questions, bug reports, etc.
There is a lot to do! The idea is to end up with a real
IDE for LaTeX on the web. When the editor project is
a little further along, I'll use is as the editor for
\\href{https://minilatex.lamdera.app}{minilatex.lamdera.app}.

\\begin{obeylines}
Jim Carlson
email: jxxcarlson@gmail.com
Elm slack: jxxcarlson
Twitter: @epsilon2718
\\href{https://github.com/jxxcarlson/elm-editor}{Github repo: post issues!}
\\end{obeylines}

\\par

\\image{https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSKK5oCbORAuRM5xZjVTqEIsRGiFjTStX4euA&usqp=CAU}{What 4 billion years of evolution can come up with}{width: 500}
"""


long =
    """

\\title{Sample MiniLaTeX Doc}

\\begin{mathmacro}
\\newcommand{\\bt}[1]{\\bf{#1}}
\\newcommand{\\mca}[0]{\\mathcal{A}}
\\end{mathmacro}

\\begin{textmacro}
\\newcommand{\\boss}{Phineas Fogg}
\\newcommand{\\hello}[1]{Hello \\strong{#1}!}
\\newcommand{\\reverseconcat}[3]{#3#2#1}
\\end{textmacro}

\\maketitle

% EXAMPLE 1

\\tableofcontents

\\section{Introduction}

MiniLatex is a subset of LaTeX that can be
rendered live in the browser using a custom just-in-time compiler.
Mathematical text is rendered by \\href{https://mathjax.org}{MathJax}:

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
your own text. Use the \\blue{export} button
below to export the text you write to a
LaTeX document on your computer.  It can
be processed as-is by any program that runs LaTeX,
e.g, TeXShop or \\code{pdflatex}.


Images in MiniLaTeX are accessed by URL (see the example
in section 4 below). When you export a document, images
used in it will be listed to the right
of the rendered text.  To use them in the exported
document, right (option) click on the image and
save it in a folder named \\italic{image}.

For more information about
the MiniLaTeX project, please go to
\\href{https://minilatex.io}{minilatex.io},
or write to jxxcarlson at gmail.

\\section{Try it out}

\\italic{Try editing formula \\eqref{integral:xn} or \\eqref{integral:exp} below.}
Note, e.g., from the source text, that the formulas are written inside
equation environments.

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

\\section{SVG}

\\begin{svg}
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0" y="0" width="381.603" height="250.385" viewBox="0, 0, 381.603, 250.385">
  <g id="Layer_1">
    <g>
      <path d="M95.401,166.09 L71.5,124.692 L95.401,83.295 L143.203,83.295 L167.103,124.692 L143.202,166.09 z" fill="#CCDD10"/>
      <path d="M95.401,166.09 L71.5,124.692 L95.401,83.295 L143.203,83.295 L167.103,124.692 L143.202,166.09 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M166.401,126.09 L142.5,84.692 L166.401,43.295 L214.203,43.295 L238.103,84.692 L214.202,126.09 z" fill="#0D9B53"/>
      <path d="M166.401,126.09 L142.5,84.692 L166.401,43.295 L214.203,43.295 L238.103,84.692 L214.202,126.09 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M167.401,207.885 L143.5,166.487 L167.401,125.09 L215.203,125.09 L239.103,166.487 L215.202,207.885 z" fill="#0D9B53"/>
      <path d="M167.401,207.885 L143.5,166.487 L167.401,125.09 L215.203,125.09 L239.103,166.487 L215.202,207.885 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M309.401,209.885 L285.5,168.487 L309.401,127.09 L357.203,127.09 L381.103,168.487 L357.203,209.885 z" fill="#0D9B53"/>
      <path d="M309.401,209.885 L285.5,168.487 L309.401,127.09 L357.203,127.09 L381.103,168.487 L357.203,209.885 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M309.401,125.09 L285.5,83.692 L309.401,42.295 L357.203,42.295 L381.103,83.692 L357.203,125.09 z" fill="#0D9B53"/>
      <path d="M309.401,125.09 L285.5,83.692 L309.401,42.295 L357.203,42.295 L381.103,83.692 L357.203,125.09 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M23.401,126.09 L-0.5,84.692 L23.401,43.295 L71.203,43.295 L95.103,84.692 L71.203,126.09 z" fill="#0D9B53"/>
      <path d="M23.401,126.09 L-0.5,84.692 L23.401,43.295 L71.203,43.295 L95.103,84.692 L71.203,126.09 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M237.401,84.295 L213.5,42.897 L237.401,1.5 L285.203,1.5 L309.103,42.897 L285.203,84.295 z" fill="#CCDD10"/>
      <path d="M237.401,84.295 L213.5,42.897 L237.401,1.5 L285.203,1.5 L309.103,42.897 L285.203,84.295 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M239.401,249.885 L215.5,208.487 L239.401,167.09 L287.203,167.09 L311.103,208.487 L287.203,249.885 z" fill="#CCDD10"/>
      <path d="M239.401,249.885 L215.5,208.487 L239.401,167.09 L287.203,167.09 L311.103,208.487 L287.203,249.885 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M94.401,84.295 L70.5,42.897 L94.401,1.5 L142.203,1.5 L166.103,42.897 L142.202,84.295 z" fill="#CCDD10"/>
      <path d="M94.401,84.295 L70.5,42.897 L94.401,1.5 L142.203,1.5 L166.103,42.897 L142.202,84.295 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
    <g>
      <path d="M333.302,94.897 C327.411,94.897 322.635,90.328 322.635,84.692 C322.635,79.056 327.411,74.487 333.302,74.487 C339.193,74.487 343.968,79.056 343.968,84.692 C343.968,90.328 339.193,94.897 333.302,94.897 z" fill="#D60B8E"/>
      <path d="M333.302,94.897 C327.411,94.897 322.635,90.328 322.635,84.692 C322.635,79.056 327.411,74.487 333.302,74.487 C339.193,74.487 343.968,79.056 343.968,84.692 C343.968,90.328 339.193,94.897 333.302,94.897 z" fill-opacity="0" stroke="#000000" stroke-width="1"/>
    </g>
  </g>
</svg>
\\end{svg}

\\section{Lists}

\\begin{itemize}

\\item This is \\strong{just} a test.

\\item \\italic{And so is this:} $a^2 + b^2 = c^2$

\\begin{itemize}

\\item Items can be nested

\\item And you can do this: $ \\frac{1}{1 + \\frac{2}{3}} $

\\end{itemize}

\\end{itemize}

\\section{Tables}

\\begin{indent}
\\begin{tabular}{ l l l l }
Hydrogen & H & 1 & 1.008 \\\\
Helium & He & 2 & 4.003 \\\\
Lithium& Li & 3 & 6.94 \\\\
Beryllium& Be& 4& 9.012 \\\\
\\end{tabular}
\\end{indent}

\\section{Math-mode macros}

Math-mode macros are added using the \\code{mathmacro} environment:

\\begin{verbatim}
\\begin{mathmacro}
\\newcommand{\\bt}[1]{\\bf{#1}}
\\newcommand{\\mca}[0]{\\mathcal{A}}
\\end{mathmacro}
\\end{verbatim}

Then saying

\\begin{verbatim}
 $$
 a^2 = \\bt{Z}/\\mca
 $$
\\end{verbatim}

yields

$$
a^2 = \\bt{Z}/\\mca
$$

Likewise, saying

\\begin{verbatim}
\\begin{equation}
\\label{eq:function.type}
\\mca^{\\bt{Z}} = \\bt{Z} \\to \\mca
\\end{equation}
\\end{verbatim}

yields

\\begin{equation}
\\label{eq:function.type}
\\mca^{\\bt{Z}} = \\bt{Z} \\to \\mca
\\end{equation}

There are some restrictions:

\\begin{verbatim}
1. No regions, e.g, use \\bf{#1},
   not {\\bf #1}

2. Macros with no arguments:
   Say \\newcommand{\\mca}[0]{\\mathcal{A}},
   not \\newcommand{\\mca}{\\mathcal{A}}

3. No recursion: the body of the macro
   cannot refer to other macros defined
   in the mathmacro environment.

4. Put the mathmacro environment at
   the beginning of the document
\\end{verbatim}

Items 1—3 will be eliminated in a
future release.

\\section{Text-mode Macros}

Text-mode macros are defined in a \\code{textmacro} environment:

\\begin{verbatim}
\\begin{textmacro}
\\newcommand{\\boss}{Phineas Fogg}
\\newcommand{\\hello}[1]{Hello \\strong{#1}!}
\\newcommand{\\reverseconcat}[3]{#3#2#1}
\\end{textmacro}
\\end{verbatim}

Then

\\begin{verbatim}
\\italic{My boss is \\boss.}
\\end{verbatim}

produces \\italic{My boss is \\boss.}
Likewise, the text

\\begin{verbatim}
\\hello{John}
\\end{verbatim}

yields \\hello{John}.

\\section{MiniLatex Macros}

MiniLatex has a number of macros of its own,  For
example, text can be rendered in various colors, \\red{such as red}
and \\blue{blue}. Text can \\highlight{be highlighted}
and can \\strike{also be struck}. Here are the macros:

\\begin{verbatim}
\\red
\\blue
\\highlight
\\strike
\\end{verbatim}

\\section{Errors and related matters}

Errors, as illustrated below, are rendered in real time and are reported in red, in place.
For example, suppose you type the  text

\\begin{verbatim}
  $$
  a^2 + b^2 = c^2
\\end{verbatim}

Then you will see this in the rendered text window:

\\image{http://jxxcarlson.s3.amazonaws.com/miniLaTeXErrorMsg-2020-02-22.png}{Fig 2. Error message}{width: 200}

We plan to make further improvements in error reporting.

\\section{More about MiniLaTeX}

This app is intended as a bare-bones demonstration of what one can do with MiniLaTeX.
There are several other apps in various stages of development which
offer different or more sophisticated services:

\\begin{itemize}

\\item \\href{https://knode.io}{knode.io} is a web app for creating, editing, and distributing
MiniLaTeX documents.  Try this link: \\href{https://knode.io/424}{QM class notes on knode.io}.
Public documents can be read by anyone, but to create documents, you need to create an account
on knode.io.

\\item \\href{https://reader.minilatex.app}{reader.minilatex.app} is a read-only app for
distributing MiniLaTeX documents on the web.  Good for class notes and the like.

\\item \\italic{In development}: a desktop app for creating MiniLaTeX content. Documents
are stored on your computer's hard disk and can also be stored in the cloud.
Documents can also be posted to any website that implements the app's publishing
protocol.  The desktop app supports two document formats: MiniLaTeX and MathMarkdown,
a version of Markdown that can render math-mode LaTeX.

\\end{itemize}

For more information about these or related apps, please contact jxxcarlson at gmail.
Bug reports and feature requests are best posted on
the \\href{https://github.com/jxxcarlson/meenylatex}{Github repo} for this project,
but email is also OK.

\\section{The Technology}

MiniLatex is written in \\href{https://elm-lang.org}{Elm}, the statically typed functional
programming language created by Evan Czaplicki for building web applications.  Because of its excellent
\\href{https://package.elm-lang.org/packages/elm/parser/latest}{parser combinator library},
Elm is a good fit for a project like the present one.  Math-mode LaTeX is rendered
by \\href{https://mathjax.org}{MathJax}.  It is a pleasure to thank Davide Cervone for his
generous help with MathJax.

For an overview of the design of MiniLatex, see
\\href{https://hackernoon.com/towards-latex-in-the-browser-2ff4d94a0c08}{Towards Latex in the Browser}.
Briefly, \\href{https://www.mathjax.org/}{MathJax} is used for math-mode
text and Elm is used for text-mode material.

One feature of note is the default incremental
parsing and rendering of source text, which is needed for responsive live editing.
Source text is divided into logical paragraphs: ordinary paragraphs or an outer
begin-end block.  When a logical paragraph is modified, only that paragraph
is recompiled.  The upside of this strategy is that recompilation is very fast.
The downside is that numbering and cross-references can get out of sync.  Press
the \\blue{Full Render} button to recompile the entire document and bring everything
into sync.

\\href{https://github.com/jxxcarlson/meenylatex}{Github repo}

\\medskip

\\section{References}

\\begin{thebibliography}

\\bibitem{G} James Carlson, \\href{https://knode.io/628}{MiniLaTeX Grammar},

\\bibitem{H} James Carlson, \\href{https://hackernoon.com/towards-latex-in-the-browser-2ff4d94a0c08}{Towards LaTeX in the Browser }, Hackernoon

\\bibitem{S} \\href{http://package.elm-lang.org/packages/jxxcarlson/minilatex/latest}{Source code}

\\bibitem{T} James Carlson, \\href{https://knode.io/525}{MiniLatex Technical Report}

\\end{thebibliography}

"""
