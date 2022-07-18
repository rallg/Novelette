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
%   fp xifthen xstring euenc fontspec tipa xunicode adjustbox eso-pic lipsum
%   makecmds polyglossia microtype xcolor xkeyval changepage import
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
\title{IMPORTANT : Provide book title}
\author{}
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

\RequirePackage{Novelette-Messages} % Errors and Warnings.
\RequirePackage{Novelette-Settings} % Define \purpose, \template, \format, etc.

\RequirePackage{silence}
\WarningFilter{hyperref}{Draft mode on} % Always on, just within hyperref.
\WarningFilter{microtype}{I cannot find a protrusion list} % It's not there!
\WarningsOff[Fancyhdr,fancyhdr] % Complains about headheight when no header.

\RequirePackage[relative]{textpos} % For inserting images.
\RequirePackage{calc} % For length expression calculations.
\RequirePackage{atbegshi} % In oberdiek bundle. For one-page header changes.
\RequirePackage{letltxmacro} % For re-defining some commands.
\RequirePackage{xparse} % For writing cool-looking commands.
\RequirePackage{noindentafter} % For unindented section and scene starts.
\RequirePackage{changepage} % Provides block indents, etc. Do not use strict!
\RequirePackage{import} % For simpler paths to your files.

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
%% Some packages, especially older ones, expect that your document class
%% pre-set some values, by class options. But Novelette does not do that,
%% because most values are not set until \AtEndPreamble.
%% This normalsize is temporary, so that packages can load without complaint.
%% It will be modified later, during layout calculations.
%% Actual default font size will be 11.5pt-12pt, with 11.7pt average.
%% The small temporary size is to ensure that overly-large struts and skips
%%   are not created prior to page layout calculation.
\gdef\@tempPS{12}
\gdef\@tempBLS{15}
\renewcommand\normalsize{\@setfontsize\normalsize{\@tempPS}{\@tempBLS}}
\normalsize
\RequirePackage[no-math,quiet]{fontspec} % For LuaLaTeX. NOT package `fontenc'.
%% End temporary normal point size, baselineskip, and fontspec.

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
\setotherlanguage{english} % For lipsum, etc.

%% Additional Macros, Loaded in Preamble.
%% ----------------------------------------------------------------------------
\RequirePackage{Novelette-Unchained} % Removes many inappropriate TeX values.
\RequirePackage{Novelette-Fonts} % Font settings and defaults.
\if@cover\else\RequirePackage[language=english]{lipsum}\fi % Dummy text.
% Macros for use in document body:
\RequirePackage{Novelette-TextMacros}
% Standard header styles, based on `fancyhdr':
% Each pre-configured style will set these booleans true or false:
\RequirePackage{fancyhdr}
\RequirePackage{Novelette-Header}
% Section and Scene styles:
\RequirePackage{Novelette-Sections}
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
  \let\RequirePackage\gimmedat
  \RequirePackage{Novelette-Templates}
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
\AtBeginDocument{ %
  \@ActivateTextLengths % In file Novelette-TextMacros.sty.
  \@ActivateHeader % In file Novelette-Header.sty.
  \@ActivatePDFInfo % In file Novelette-PDFX.sty.
  \@ActivateTextMacros % In file Novelette-TextMacros.sty.
  \@ActivateFootnotes % In file Novelette-Footnotes.sty.
  \@DisableMetadataCommands % In file Novelette-Metadata.sty.
  \@RedefineBreakpos % In file Novelette-Sections.sty.
  % Cover has no content other than background image. End input now.
  % Then the log file will say that there was an unfinished if. Indeed! 
  \if@cover\thispagestyle{empty}\null\end{document}\fi
  \catcode`\@=12
  \catcode`\#=12
  \catcode`\$=12
  \catcode`\^=12
  \catcode`\&=12
  \catcode`\_=12
}
%% End \AtBeginDocument.


%% AtEndDocument adds one or two blank pages, required by printers.
%% Also writes list of inspected, good images to aux, for later use:
\AtEndDocument{%
  \if@cover\else%
    \immediate\write\@auxout{%
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

