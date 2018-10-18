<h1 align="center">VocalMat</h1>
<div align="center">
    <strong>Automated Tool for Mice Vocalization Detection and Classification</strong>
</div>

<div align="center">
    <br />
    <a href="http://www.dietrich-lab.org"><img src="logo.png" title="Dietrich Lab - Yale School of Medicine" alt="Dietrich Lab - Yale School of Medicine"></a>
</div>

<div align="center">
    <sub>This tool was built @ Dietrich Lab, Department of Comparative Medicine, Yale University.
</div>

<div align="center">
    <br />
    <!-- MATLAB version -->
    <a href="https://www.mathworks.com/products/matlab.html">
    <img src="https://img.shields.io/badge/MATLAB-2017a%7C2017b%7C2018a%7C2018b-blue.svg?style=flat-square"
      alt="MATLAB tested versions" />
    </a>
    <!-- LICENSE -->
    <a href="#">
    <img src="https://img.shields.io/badge/license-whatever-orange.svg?style=flat-square"
      alt="MATLAB tested versions" />
    </a>
    <br />
</div>

## Table of Contents
- [Description](#description)
- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [FAQ](#faq)
- [License](#license)

---
---
---

## Description
> **VocalMat is an automated tool that identifies and classifies mice vocalizations.**

<p align="justify"> VocalMat is divided into two main components. The VocalMat Identifier, and the VocalMat Classifier.

![VocalMat Workflow](vocalmat.png)

<p align="justify"> VocalMat Identifier is responsible for identifying possible vocalizations in the provided audio file. Candidates for vocalization are further analyzed and regions identenfied as noise are removed. The VocalMat Identifier outputs a MATLAB formatted file (.MAT) with information about identified vocalizations (e.g., frequency, vocalization intensity, timestamp), that is later used by the VocalMat Classifier.

<p align="justify"> VocalMat Classifier uses a Convolutional Neural Network (CNN) to classify vocalization into 13 labels: short, flat, chevron, reverse chevron, downward frequency modulation, upward frequency modulation, complex, multi steps, two steps, step down, step up, and noise.


## Features
- __11 Classification Classes:__ VocalMat is able to distinguish between 11 classes of vocalizations
- __Noise Detection:__ eliminates noisy sections that would otherwise be identified as vocalizations
- __Harmonic Detection:__ detects when vocalizations have steps in frequency
- __Fast Performance:__ optimized versions for personal computers and high-performance computing (clusters)

## Getting Started
![Recordit GIF](clone.gif)

#### Latest Stable Release
```bash
$ git clone https://github.com/ahof1704/VocalMat.git
```

#### Requirements
- __MATLAB:__ version 2017a, 2017b, 2018a, or 2018b. For other versions refer to the [FAQ](#faq).
- __MATLAB Add-Ons:__
    - Computer Vision System Toolbox
    - Control System Toolbox
    - Curve Fitting Toolbox
    - Deep Neural Network
    - DSP System Toolbox
    - Fuzzy Logic Toolbox
    - Image Processing Toolbox
    - Instrument Control Toolbox
    - Neural Network Toolbox
    - Optimization Toolbox
    - Parallel Computing Toolbox
    - Simulink
    - Simulink Control Design
    - Signal Processing Toolbox
    - Statistics and Machine Learning Toolbox
    - Symbolic Math Toolbox

#### Directory Structure
- __vocalmat_identifier:__ everything related to the VocalMat Identifier
- __vocalmat_classifier:__ everything related to the VocalMat Classifier
- __audios:__ place the audio files you want to process in the `audios` directory
- __outputs:__ all output files from VocalMat will be placed in the `outputs` directory
- __.workarea:__ files that are still under development, do not use

## Usage

#### `VocalMat` Manual Execution
<p align="justify">Navigate to the <i>vocalmat_identifier</i> directory and open <i>identifier.m</i> in MATLAB. Run and choose the audio file you want to analyze. Once finished, that <i>Identifier</i> will output two .MAT files in the same directory that the audio file is in, <i>output_*.mat</i> and <i>output_sorter_*.mat</i>. Next, navigate to <i>vocalmat_classifier</i> and open <i>classifier.m</i> in MATLAB. Run and choose the <i>output_*.mat</i> that the <i>Identifier</i> outputed. The <i>Classifier</i> will create a directory with its outputs (vocalizations and classifications) in that same directory that the audio file is in.

#### `VocalMat` Output Files

<p align="justify">VocalMat outputs a directory with the same name of the audio file that was processed. Inside that directory there are two directories (<i>All</i>, <i>All_axes</i>), and one Microsoft Excel (.xlsx) file. Inside <i>All_axes</i> you will find one image for each segment identified as a vocalization (with plotted blue circles). The raw original images are available inside <i>All</i>. The Excel file contains information on each vocalization, such as start and end time, duration, vocal intensity, and classification.

#### Personal Use (bash script)
```bash
$ ./run_identifier_local [OPTIONS]
```
##### Examples
VocalMat help menu
```bash
$ ./run_identifier_local -h
or
$ ./run_identifier_local --help
```
Running VocalMat using 4 threads:
```bash
$ ./run_identifier_local -c 4
or
$ ./run_identifier_local --cores 4
```

#### High-Performance Computing (Clusters with Slurm Support, bash script)
```bash
$ ./run_identifier_cluster [OPTIONS]
```
##### Examples
Running VocalMat and getting execution (slurm) notifications to your email:
```bash
$ ./run_identifier_cluster -e your@email.com
or
$ ./run_identifier_cluster --email your@email.com
```

Running VocalMat using 4 cores, 128GB of RAM, walltime of 600 minutes, and getting notifications to your email:
```bash
$ ./run_identifier_cluster -e your@email.com -c 4 -m 128 -t 600
or
$ ./run_identifier_cluster --email your@email.com --cores 4 --mem 128 --time 600
```

## FAQ
- Will `VocalMat` work with my MATLAB version?
<p align="justify">VocalMat was developed and tested using MATLAB 2017a, 2017b, 2018a, and 2018b versions. We cannot guarantee that it will work in other versions of MATLAB. If your MATLAB versions supports all the required Add-Ons, VocalMat should work.

- What are the hardware requirements to run `VocalMat`?
<p align="justify">The duration of the audio files that can you use in VocalMat is limited to the amount of RAM that you have in your computer. We estimate around 1GB of RAM for every minute of recording using one minute segments. For a 10 minute recording, you should have at least 10GB of RAM available. RAM usage will vary depending on your MATLAB version and computer, these numbers are just estimates.

- Will `VocalMat` work with my HPC Cluster?
<p align="justify"> In order for our script to work in your Cluster it must have Slurm support and have both deadSimpleQueue and MATLAB modules. We use the standard `module load` command to load modules. Minor changes might have to be made to adapt the script to your Cluster configuration.

## License
<div>
    <a href="#">
    <img src="https://img.shields.io/badge/license-whatever-orange.svg?style=flat-square"
      alt="MATLAB tested versions" />
    </a>
</div>

- **[whatever license](#)**
- Copyright 2018 © <a href="http://www.dietrich-lab.org" target="_blank">Dietrich Lab</a>.

If you use VocalMat or any part of it in your own work, please cite [Fonseca et al](#):
```
(to appear)
@article{vocalmat,
    author =       "",
    title =        "",
    journal =      "",
    volume =       "",
    number =       "",
    pages =        "",
    year =         ""
}
```