this is an example I point people to when I
explain how to compile cu with cpp files [this being one way] -- look in releases for example project

Use   extern "C" int foo(){code goes here}    on where you want to have a function that branches accross multipul file types 

then for where you want to use the file, do (at start if file without an include to your cu or cpp file) extern "C" int foo();   then you can call it with foo();  

(The main part  -->  -Xcompiler "/wd 4819"    <-- this should be in your command line addition option for CUDA C/C++ section of visual studio)


make sure the project this is done in is using the CUDA build custom
