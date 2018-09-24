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
    <img src="https://img.shields.io/badge/MATLAB-2017a%7C2017b%7C2018a-blue.svg?style=flat-square"
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
- [Support](#support)
- [License](#license)

---
---
---

## Description
> **VocalMat is an automated tool that identifies and classifies mice vocalizations.**

<p align="justify">
The tool is divided into two main components. The Vocal Identifier, and the Vocal Classifier.

> IMAGE SHOWING VOCALMAT WORKFLOW

<p align="justify">
Vocal Identifier is responsible for identifying possible vocalizations in the provided audio file. Candidates for vocalization are further analyzed and regions identenfied as noise are removed. The VocalMat Identifier outputs a MATLAB formatted file (.MAT) that contains information about identified vocalizations (*e.g.* frequency, vocalization intensity, timestamp).

<p> Vocal Classifier ...


## Features
- __11 Classification Classes:__ VocalMat is able to distinguish between 11 classes of vocalizations
- __Noise Detection:__ eliminate noisy sections that would otherwise be identified as vocalizations
- __Harmonic Detection:__ detect when vocalizations have large steps in frequency
- __Fast Performance:__ optimized versions for personal computers, high-performance computing in clusters, and GPUs

## Getting Started
![Recordit GIF](clone.gif)

#### Latest Stable Release
```bash
$ git clone https://github.com/ahof1704/VocalMat.git
```
#### Directory Structure
- __vocalmat_identifier:__ everything related to the identifier
- __vocalmat_classifier:__ everything related to the identifier
- __audios:__ place the audio files you want to process here
- __outputs:__ all outputs from VocalMat will be placed in this directory
- __.workarea:__ files that are still under development, do not use

## Usage
#### Personal Use
#### High-Performance Computing (Clusters with Slurm Support)
#### GPU Acceleration

## FAQ
## Support
## License
<div>
    <a href="#">
    <img src="https://img.shields.io/badge/license-whatever-orange.svg?style=flat-square"
      alt="MATLAB tested versions" />
    </a>
</div>

- **[whatever license](#)**
- Copyright 2018 © <a href="http://www.dietrich-lab.org" target="_blank">Dietrich Lab</a>.

If you use this tool in your own work, please cite [Fonseca et al](#):
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