This is Muse, which stands for Mouse Ultrasonic Source Estimator.  It
does sound-source localization of ultrasonic mouse vocalizations.

The core function of Muse is r_est_from_clip_simplified(), located in
toolbox/r_est_from_clip_simplified.m.  See the documentation within
that file for how to invoke it and how to interpret its output.  This
was the function used to estimate position from individual "snippets"
in Neunuebel et al. 2015.  You can run the script
test_with_synthetic_data.m to see an example of how to call
r_est_from_clip_simplified() on, you guessed it, synthetic data.

This version of Muse depends on the Matlab Signal Processing and
Statistics toolboxes, and on the Taylor Matlab Toolbox, release
1.14.

A MATLAB-based data acquisition function that uses a National
Instruments board (rec_pb_3_jpn.m) is included in the repository, but
vocalizations can also be recorded using your favorite data
acquisition software.  To prepare vocalizations for localization, they
should almost certainly should be cut out using Ax
(https://github.com/JaneliaSciComp/Ax).

All code in Muse, except that in toolbox/snippeter, is copyright Adam
L. Taylor, 2013-2015.  It is licensed under the BSD 2-clause license.
(See below.)

Copyright (c) 2013-2015, Adam L. Taylor
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the
   distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation
are those of the authors and should not be interpreted as representing
official policies, either expressed or implied, of Adam L. Taylor or
the Howard Hughes Medical Institute.

