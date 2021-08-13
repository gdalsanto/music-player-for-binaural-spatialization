This folder contains modified versions of the source codes of partconv_tilde and convolve_tilde
The objective is that of changing the IRs in real-time without artifacts 
None of the following mods is artifact-free 

List of mods
- mod01: loading of the impulse responses from header file 
- mod02: store the impulse repsonses into a structure
- mod03: overwrite the buffers

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

How to compile a pd object with MINGW64 (thanks to lucarda for the help)

1) Install the compiler and the fftw library 

Download the 64-bit installer from: https://www.msys2.org/
Follow installation instructions on: https://www.msys2.org/wiki/MSYS2-installation/
Add with pacman these packages:

    pacman -S make pkg-config autoconf automake libtool

Then the 32-bit compiler:

    pacman -S mingw32/mingw-w64-i686-gcc
    
Then the 64-bit compiler:

    pacman -S mingw64/mingw-w64-x86_64-gcc 
    
Add fftw (here we add the 64-bit lib):

    pacman -S mingw64/mingw-w64-x86_64-fftw
        
If you have downloaded with Deken (aka Pd menu help / find externals) the pkg:

    bsaylor[v0.1.4](Windows-amd64-32)(Sources).dek
        Uploaded by lucarda @ 2018-09-29 11:33:54
     
you can open the MinGW64 shell and cd to that dir (most likely "C:\Users\<your user>\Documents\Pd\externals\bsaylor" with:

    cd C:/Users/<your user>/Documents/Pd/externals/bsaylor/src
    
(note the "/" slashes instead of backslashes "\". )
    
Then just run:

    make
    
This will most likely compile. Then you need to copy the fftw3 dlls (most likly named "libfftw3-3.dll libfftw3f-3.dll") needed at runtime. They typically are in the

    C:\msys64\mingw64\bin
    
folder. You need to copy them to "C:/Users/<your user>/Documents/Pd/externals/bsaylor/src".

Then copy the help patches from 
    "C:/Users/<your user>/Documents/Pd/externals/bsaylor" 
to 
    "C:/Users/<your user>/Documents/Pd/externals/bsaylor/src"
    
Then open the help patches in this last folder.

PS: pd-lib-builder is included in the src folder. You can later edit the .c files in the src folder and recompile.

PS2: you can use:

    make clean
    
to clean the .dlls and .o files.

2) Compile the modified version of the object's source code
Open MinGW64 shell an cd to tour extracted "Gloria-partconv~" folder.
Type

     	make

Add the libfftw3f-3.dll in folder where the .c file is (ex: mod01)
Open an explorer in "C:\msys64\mingw64\bin"
Copy libfftw3f-3.dll
Paste it on folder where the .c file (you have to do this only on first compile)
From the MinGW64 window type

	make

to recompile.
