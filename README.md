-*- mode: org -*-
#+TAGS: Complete UnDocumented InComplete Obsolete Planned

* About

This repository contains a collection of working, unfinished as well as
abandoned functions. They serve various tasks although most of them are related
to image processing tasks.

Note that the functions have been designed for usability and not necessarily for
speed and memory efficiency. The functions do some thorough checks of all the
passed arguments and are very flexible when it comes to parameter settings,
without cluttering the the function calls with countless unnecessary
parameters. Also note, that most functions are not necessarily compatible to GNU
Octave, Scilab and/or other software that tries to offer a free alternative to
Matlab. Although it often would only require trivial changes to make it
compatible. Concerning GNU octave, one could probably obtain almost complete
compatibility by simply removing the input parser.

* Function Listing

  The functions are grouped (by theme) into different folders. The Tag indicates
  the current status of the file.

** Generic

*** FindAbsLargest						 :InComplete:
*** FindAbsSmallest						 :InComplete:
*** FindLargest							 :InComplete:
*** FindSmallest						 :InComplete:
*** FirmShrink							 :InComplete:
*** GarroteShrink						 :InComplete:
*** HardShrink							 :InComplete:
*** LinearShrink						 :InComplete:
*** SoftShrink							 :InComplete:
*** Threshold							 :InComplete:

** LinearAlgebra

*** CanonicBasisVector						   :Complete:
*** CircShift							   :Complete:
*** DiffFilter1D						   :Complete:
*** ExtractEntries						   :Complete:
*** FiniteDiff1DM						   :Complete:
*** GradientM							   :Complete:
*** IsInteger							   :Complete:
*** IsSquareMatrix						   :Complete:
*** KroneckerSum						   :Complete:
*** LaplaceM							   :Complete:

** ImageAnalysis

*** ImageAdjust 						    :Planned:
*** ImageClip							    :Planned:
*** ImageDeriv							   :Complete:
*** ImageDiv							   :Complete:
*** ImageDx							   :Complete:
*** ImageDxx							   :Complete:
*** ImageDxy							   :Complete:
*** ImageDy							   :Complete:
*** ImageDyy							   :Complete:
*** ImageGrad							   :Complete:
*** ImageGradMag						   :Complete:
*** ImageHess							   :Complete:
*** ImageLapl							   :Complete:
*** ImagePad							   :Complete:
*** ImagePyramid						   :Complete:
*** ImageQuantize						    :Planned:
*** ImageSmooth							   :Complete:
*** ImageThreshold						    :Planned:
*** ImageToVector						   :Complete:
*** IsImage							   :Complete:
*** MeanSquareError						   :Complete:
*** MirrorEdges							   :Complete:
*** PeakSignalToNoiseRatio					   :Complete:

** System

*** ReturnDocString					       :UnDocumented:
*** UpdateFunction					       :UnDocumented:
*** CreateTemplate					       :UnDocumented:
*** InsertDocString					       :UnDocumented:
