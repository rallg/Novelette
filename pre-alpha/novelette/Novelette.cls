%%
%% This is file Novelette.cls, LuaLaTeX Novelette document class.
%% Copyright 2022 Robert Allgeyer. GitHub user 'rallg'.
%%
%% It may be used, distributed, and/or modified under the
%% conditions of the MIT License. See:
%% https://opensource.org/licenses/MIT
%% 

\ProvidesClass{Novelette}[2022/06/22 v0.0.1 LuaLaTeX document class]

%% REQUIRES LUALATEX AND/OR LUAHBTEX.
% If your TeX setup does not have either program `lualatex' or `luahbtex'
% then you did not install LuaTeX support. Re-install TeX, and do that.
% If your TeX installation has `luahbtex' but not `lualatex'
% (which is probably a symlink to `luahbtex') then do one of these:
%   a) If admin privilege, enter the directory containing program `luahbtex'.
%      Command-line:  ln -s luahbtex lualatex && hash lualatex
%      Then return to wherever you were. Should work immediately. Permanent.
%   b) If your home directory has a `.bashrc' file (or you create it),
%      Then add this:  alias lualatex='luahbtex --fmt=lualatex'
%      Then logout/login (or source ~/.bashrc). Effect is permanent.
%   c) Command-line:  alias lualatex='luahbtex --fmt=lualatex'
%      The effect is immediate, but is lost when you logout.

%% REQUIRED TEX PACKAGES
% Be sure that your TeX installation has LuaTeX, and at least minimal LaTeX.
% Also have English language, even if you are writing in another language.
% If your TeX installation is very minimal, then you will need to install
% additional packages. A program such as MikTeX (Windows) can automatically
% do it for you, as it goes along. On Linux (maybe Mac) you will need to
% use the 'tlmgr' command-line to install packages yourself.
% These are the ones most likely to be needed, beyond the minimal:
%   fp xifthen xstring euenc fontspec tipa xunicode adjustbox eso-pic
%   lipsum makecmds polyglossia microtype xcolor xkeyval changepage magaz
%   noindentafter pdfpages ifmtarg xpatch collectbox pgf pdflscape

%% DESCRIPTION:
%% ----------------------------------------------------------------------------
% Novelette is designed for print fiction: Novelettes or short stories.
% Is is simplified, for those who do not need all TeX advanced features.
% Novelette cannot be used for e-books or for journal publication.
% It is not suitable for most non-fiction, because routine academic features
% (such as bibiography and automatic sectioning) are defeated.
%
% There are pre-configured layouts for the most commonly used choices of
% trim size (finished book width and height), and internal layout consistent
% with fiction. The user can over-ride the pre-configured settings.
%
% The class will automatically create PDF/X files upon request,
% using a self-contained command structure. Compliance has been tested,
% but is not guaranteed. you may need to check it using professional software.
%
% LuaLaTeX is required, and input files must be encoded utf-8.
% Fonts are loaded by luaotfload and fontspec, and massaged by microtype.
% Use only modern OpenType fonts, or TrueType fonts. Not Type1, metafont, etc.


%% PRELIMINARY SETUP
%% ----------------------------------------------------------------------------
%% These are not user settings.
\RequirePackage{iftex} % Checks how you are trying to compile your document.
\RequirePackage{luatex85} % Needed for compatibility with older software.
\RequirePackage{pdftexcmds} % Needed for compatibility with older software.
\ifluatex
  \pdfvariable suppressoptionalinfo 511 % Writes only ID to PDF Catalog.
\else
  \ClassError{Novelette}{Must compile with lualatex.}%
   {Use lualatex only. Not luatex, pdftex, dvips, or xetex. ^^J%
    Can also use `luahbtex --fmt=lualatex' as equivalent.}
\fi
\pdfimageresolution=300 % Default dpi if image does not say.
\pdfminorversion=3 % Might be reset later, depending on settings.
\gdef\thepdfminorversion{\pdfminorversion} % Compatibility with older software.
% Global lengths are often passed around in Novelette.
% But \setlength is not always global in effect.
% This code defines a global command.
% Via Heiko Oberdiek at tex.stackexchange.com:
\gdef\gsetlength#1#2{% #1 is the length command, #2 is the length value
  \begingroup%
    \setlength\skip@{#2}% Local assignment to a TeX scratch register.
    \global#1=\skip@% Global assignment to #1
  \endgroup% \skip@ is restored by end of group.
}% End \gsetlength.
\newlength\@tempLength % Scratch length for local calculations.
\newif \if@tempTF % Scratch boolean for local tests.
\RequirePackage{etoolbox} % General good stuff.
\RequirePackage{xstring} % Parses strings.
\RequirePackage{xifthen} % Improved \ifthenelse handling.
\RequirePackage{fp} % Used everywhere for calculations. Includes xfp.
\FPmessagesfalse % Eliminates numerous friendly messages from the log.


%% Define \purpose{book,markup,cover}:
\newif \if@book
\newif \if@coverart
\newif \if@markupcopy
\newcommand\purpose[1]{
  \@tempTFfalse
  \ifthenelse{\equal{#1}{book}}{\@booktrue \@tempTFtrue}{}
  \ifthenelse{\equal{#1}{cover}}{\@coverarttrue \@tempTFtrue}{}
  \ifthenelse{\equal{#1}{markup}}{\@markupcopytrue \@tempTFtrue}{}
  \if@tempTF\else
    \ClassError{Novelette}{Bad choice in \string\purpose{choice}}%
    {Available choices:  book  markup  cover }
  \fi
}
\purpose{book} % Default.

%% Define \template{number}{name}:
\newif \if@templateset
\newcommand\template[2]{%
  \gdef\my@template{#1}
  \gdef\my@trimname{#2}
  \IfSubStr{1 2 3}{\my@template}{}{%
    \ClassError{Novelette}{Incorrect choice of template number}%
    {In \string\template{number}{name} number must be 1, 2, or 3.}%
  }
  \IfSubStr{Novella B Memoir Demy Digest Trade Royal}{\my@trimname}{}{%
    \ClassError{Novelette}{Incorrect choice of size name}%
    {In \string\template{number}{name} name must be one of: ^^J%
     Novella B Memoir Demy Digest Trade Royal ^^J%
     The name is case-sensitive.}%
  }
  \@templatesettrue
}
%%

%% Define \upshift{length} Tweak: Moves page content up/down..
\newlength\my@upshift
\gsetlength\my@upshift{0in}
\newcommand\upshift[1]{ % Units of mm, cm, in.
  \@tempTFfalse
  \ifthenelse{\equal{#1}{} \OR \equal{#1}{0}}{\@tempTFtrue}{}
  \IfEndWith{#1}{in}{\@tempTFtrue}{}
  \IfEndWith{#1}{mm}{\@tempTFtrue}{}
  \IfEndWith{#1}{cm}{\@tempTFtrue}{}
  \if@tempTF
    \ifthenelse{\equal{#1}{} \OR \equal{#1}{0}}{}{\gsetlength\my@upshift{#1}}
  \else
    \ClassError{Novelette}{Bad value for \string\upshift}%
    {Must be length, with units:  mm  cm  in ^^J%
     or 0, or leave empty.}
  \fi
}
%%

%% Define \media{book,markup}{width}{height}
\newif \if@MediaSize % When trim size is floated in larger PDF page size.
\newcommand\media[3]{
  \@tempTFfalse
  \ifthenelse{\equal{#1}{book}}{\@tempTFtrue}{}
  \ifthenelse{\equal{#1}{markup}}{\@tempTFtrue}{}
  \if@tempTF\else
    \ClassError{Novelette}{Bad choice for \string\media{}{}{}}%
    {First argument:  book  markup}%
  \fi
  \@tempTFfalse
  \IfEndWith{#2}{in}{\@tempTFtrue}{}
  \IfEndWith{#2}{mm}{\@tempTFtrue}{}
  \IfEndWith{#2}{cm}{\@tempTFtrue}{}
  \if@tempTF\else
    \ClassError{Novelette}{Bad choice for \string\media{}{}{}}%
    {Second argument must be width. Units: mm cm in}%
  \fi
  \@tempTFfalse
  \IfEndWith{#3}{in}{\@tempTFtrue}{}
  \IfEndWith{#3}{mm}{\@tempTFtrue}{}
  \IfEndWith{#3}{cm}{\@tempTFtrue}{}
  \if@tempTF\else
    \ClassError{Novelette}{Bad choice for \string\media{}{}{}}%
    {Third argument must be height. Units: mm cm in}%
  \fi
  \ifthenelse{\dimtest{#2}{<}{#3}}{
    \ifthenelse{\equal{#1}{book}}{
      \if@book
        \@MediaSizetrue
        \gsetlength\paperwidth{#2}
        \gsetlength\paperheight{#3}
      \fi
    }{}
    \ifthenelse{\equal{#1}{markup}}{
      \if@markupcopy
        \@MediaSizetrue
        \gsetlength\paperwidth{#2}
        \gsetlength\paperheight{#3}
      \fi
    }{}
  }{
    \ClassError{Novelette}{Bad choice for \string\media{}{}{}}%
    {Second argument is width. Third argument is height. ^^J%
     Height must be greater than width.}
  }
}
%%


\RequirePackage{silence}
\WarningFilter{hyperref}{Draft mode on} % Always on, just within hyperref.
\WarningFilter{microtype}{I cannot find a protrusion list} % It's not there!
\WarningsOff[Fancyhdr,fancyhdr] % Complains about headheight when no header.

\RequirePackage[relative]{textpos} % For inserting images.
\RequirePackage{calc} % For length expression calculations.
\RequirePackage{atbegshi} % In oberdiek bundle. For one-page header changes.
\RequirePackage{letltxmacro} % In oberdiek bundle. For re-defining some macros.
\RequirePackage{xparse} % For writing cool-looking commands. *****


\RequirePackage{noindentafter} % For unindented chapter and scene starts.
\RequirePackage{changepage} % Provides block indents, etc. Do not use strict!
\RequirePackage{magaz} % Special treatment of first lines.

%% Activate xcolor, adjustbox, and eso-pic:
%% ----------------------------------------------------------------------------
% The final book must be black/white and gray only, for all text.
% Interior images must be raster black/white or grayscale. See documentation.
%   Vector graphics are strongly discouraged, in any case.
\RequirePackage[gray,hyperref]{xcolor}
%
% adjustbox and eso-pic cannot precede xcolor.
\RequirePackage{adjustbox} % For scaling and moving.
\RequirePackage{eso-pic} % Background label in markupcopy.
\RequirePackage{pdfpages} % Used for pdf pre-processed by Novelette-scripts.


%% Temporary normal font size, baselineskip, and fontspec
%% ----------------------------------------------------------------------------
% Some packages, especially older ones, expect that your document class
% pre-set some values, by class options. But Novelette does not do it that way,
% because most values are not set until \AtEndPreamble.
%% This normalsize is temporary, so that packages can load without complaint.
%% It will be modified later, during layout calculations.
%% Actual default font size will be 11pt-12pt, with 11.4pt average.
%% The small temporary size is to ensure that overly-large struts and skips
%%   are not created prior to page layout calculation.
\gdef\@TentativeEmN{10}
\gdef\@TentativeBLSkipN{13}
\renewcommand\normalsize{%
  \@setfontsize\normalsize{\@TentativeEmN}{\@TentativeBLSkipN}%
}
\normalsize
\RequirePackage[no-math]{fontspec} % For LuaLaTeX. NOT package `fontenc'.
%% end temporary normal point size, baselineskip, and fontspec.

% This loads file Novelette-Microtype.cfg:
\gdef\@mymicrotypeset{config=Novelette-Microtype,final,stretch=20,shrink=20}
\RequirePackage[\@mymicrotypeset]{microtype}
\renewcommand\textls[2][]{##2} % Nullifies the microtype \textls (problems).


%% Define commands used for PDF Metadata, including PDF/X.
%% ----------------------------------------------------------------------------
%% PDF Metadata is in PDF/Info and in XMP. Not written to PDF Catalog.
\RequirePackage{Novelette-Metadata}
%%



%% Polyglossia.
%% ----------------------------------------------------------------------------
% Language-specific settings:
\RequirePackage{polyglossia}
\setdefaultlanguage[variant=american]{english} % May be changed by user.


%% Additional Macros, Loaded in Preamble.
%% ----------------------------------------------------------------------------
\RequirePackage{Novelette-Unchained}
\RequirePackage{Novelette-Fonts} % font settings and defaults
\if@coverart\else\RequirePackage{lipsum}\fi % generates dummy text for examples
% Macros for use in document body:
\RequirePackage{Novelette-TextMacros}
% Standard header styles, based on `fancyhdr':
% Each pre-configured style will set these booleans true or false:
\newif\if@HasHeader
\RequirePackage{fancyhdr}
\RequirePackage{Novelette-HeaderStyles}
% Chapter and Scene styles:
\RequirePackage{Novelette-ChapterScene}
% Image placement:
\RequirePackage{luacode}
\RequirePackage{Novelette-Images}
% Footnotes and endnotes:
\RequirePackage{Novelette-Footnotes}
%%

%% TeX allows you to load additional packages in Preamble, using
%% the \usepackage or \RequirePackage commands. But in order to keep Novelette
%% as self-contained as possible, those commands are nullified in the
%% interval between \documentclass{Novelette} and \AtEndPreamble.
%% So, like it or not, you cannot load any other packages.
\let\gimmedat\RequirePackage\relax
\newcommand\nomorepackages[2][]{%
  \ClassError{Novelette}{Cannot \string\usepackage or \string\RequirePackage}%
  {Novelette is self-contained. You cannot add other TeX packages. ^^J%
   This is to ensure that Novelette documentation and behavior agree. ^^J%
   If you really need to add a package, maybe you should learn TeX ^^J%
   and use a different document class? Hah! Better: Forget that package. ^^J}%
}
\let\RequirePackage\nomorepackages\relax
\let\usepackage\nomorepackages\relax


%% \AtEndPreamble sets defaults, calculates layout, and writes PDF/X
%% ----------------------------------------------------------------------------
% This is prior to \AtBeginDocument, and ensures that the results are available
%   prior to any \AtBeginDocument routines from user macros or loaded packages. 
\AtEndPreamble{
  \if@templateset\else\template{3}{Digest}\fi % Default.
  \let\RequirePackage\gimmedat
  \@ActivateFonts % In file Novelette-Fonts.sty. 
  \RequirePackage{Novelette-CalculateLayout}
  % Hyperref options for PDF/X with LuaLaTeX:
  \def\pdfx@pdfX@opts@luatex{%
    draft,pdfpagemode=UseNone,bookmarks=false,hyperfootnotes=false,%
    hyperindex=false,implicit=false,pdfversion=1.\the\pdfminorversion,%
    pdfpagelabels=true,pageanchor=false,pdfstartview=}
  \RequirePackage[\pdfx@pdfX@opts@luatex]{hyperref}
  \RequirePackage{Novelette-PDFX} % Also provides an \AtBeginDocument macro.
  \@GetInitialYpos % In file Novelette-TextMacros.sty.
}% End \AtEndPreamble.


%% \AtBeginDocument finishes the setup
%% ----------------------------------------------------------------------------
%
\AtBeginDocument{ %
  \@ActivateTextLengths % In file Novelette-TextMacros.sty.
  \@ActivateChapterScene % In file Novelette-ChapterScene.sty.
  \@ActivateHeaderStyles % In file Novelette-HeaderStyles.sty.
  \@ActivatePDFInfo % In file Novelette-PDFX.sty.
  \@ActivateTextMacros % In file Novelette-TextMacros.sty.
  \@ActivateFootnotes % In file Novelette-Footnotes.sty.
  \@DisableFontSizes % In file Novelette-Unchained.sty.
  \@DisableMetadataCommands % In file Novelette-Metadata.sty.
  \@DisableChapterSceneSettings % In file Novelette-ChapterScene.sty.
  \@RedefineBreakpos % In file Novelette-ChapterScene.sty.
  \@DisableHeaderSettings % In file Novelette-HeaderStyles.sty.
  \@GatherGoodImages % In file Novelette-Images.sty.
%%%%%  \if@markupcopy\@AddMarkupLabel\fi % In file Novelette-CalculateLayout.sty.
  % Cover has no content other than background image. End input now.
  % Then the log file will say that there was an unfinished if. Indeed! 
  \if@coverart\thispagestyle{empty}\null\end{document}\fi
}% end \AtBeginDocument
%%


%% AtEndDocument adds one or two blank pages, required by printers.
%% Also writes list of inspected, good images to aux, for later use:
\AtEndDocument{%
  \if@coverart\else%
    \immediate\write\@auxout{%
      \string\xdef\string\@AllGoodImages{\@AllGoodImages}^^J%
      \string\xdef\string\@UnknownImages{\@UnknownImages}^^J%
    }%
    \cleartoend % Adds 1 or 2 blank pages, for final verso blank.
  \fi%
}
%%


%% AfterEndDocument writes final message:
\AfterEndDocument{
  \@WarnUnknownImages % In file Novelette-Images.sty.
}
%%



%%
%% End of file Novelette.cls.

