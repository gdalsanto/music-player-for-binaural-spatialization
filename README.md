# Music Player for Binaural Spatialization 
## Scope of the project
The scope of this project is that of developing a music player for headphones capable of externalizing
the sound according to a specific environment. An intense use of conventional headphones
can lead to mental fatigue, resulting in lower reaction time and attention deficits. Externalized
sound can help coping with stress and tiredness that stereo and mono sound reproduction
systems over headphones induce to the listener. Therefore, it is of great interest to develop a
music player that helps at comparing the effects of long-term listening sessions between stereo
and externalized sound.  


The core of the presented music player is based on convolutional artificial reverberation. For the
implementation of the artificial reverberation algorithm, partitioned convolution will be used
on a set of BRIRs measured in a listening room at EPFL. The music player will communicate
with a motion sensor and use the retrieved information about the movement of the user’s head
to enhance the realism of the processed sound. It is expected that the listener will be able to
localize the sound source in the space as if it was coming from a pair of virtual loudspeakers.
The final implementation will include additional tools for the customization of the set of impulse
responses in terms of Direct-to-Reverberation energy ratio, length of the impulse response and
orientation of the sound source.
## Getting started
The music player is implemented as a Pure Data patch (path : `pure-data/final-design/music_player.pd`). In order to run it correcly, Pure Data and the following externals have to be installed:
- `iemlib` - splitfilename 
- `convolve~`
- `earplug~`  

From `./pure-data/final-design/` it is not recomanded to remove any of the files in order for Pure Data to recognize both the data and `earplug~` external.  

For the detailed descritption of the user interface, refer to chapter 4 "**User Interface and Functionalities**" of the project report. 

This repository stores two auxiliary Matlab scripts for the processing of the BRIRs.  
For the sake of completeness, the two inital designs are also included in this repository.
### Head tracker
The head tracking system is integrated with a subpatch that enables communication with the NGIMU tracking device, produced by [x-io Technologies](https://x-io.co.uk/ngimu/). Compatibility with other IMU tracking devices is not guaranteed.  
By activating the **auto** or **manual** mode, the head tracking system can work without an external sensor. 
## Author 
**Gloria Dal Santo**   
M.Sc. in Electrical and Electronic Engineering at EPFL  
B.Sc. in Electronic and Communications Engineering at Politecnico di Torino  
[Linkedin](https://www.linkedin.com/in/gloriadalsanto/)  

For any problem, issue or comment please send an email to gloria.dalsanto@outlook.it  
## Acknowledgments
The project has been supervised by 
- Vincent Grimaldi, EPFL
- Prof. Hervé Lissek, EPFL
