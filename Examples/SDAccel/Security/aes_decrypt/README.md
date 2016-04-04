AES Decryption Example
===============================

This is an optimized implementation of an AES-128 ECB Encrypt in Software, followed by OpenCL Decryption targeting execution on an SDAccel supported FPGA acceleration card.

Achieved performance was measured on an Alpha Data ADM-PCI-7v3 card.

Compiling the Application
---------------------------
This application is compiled using the SDAccel script mode.
To compile the application:

```
sdaccel aes_decrypt.tcl
```
The target board can be changed by editing *huffman.tcl*

Executing the Application
---------------------------
```
aesdecrypt_example.exe --platform Xilinx --device fpga0 --kernel bin_aes_decrypt.xclbin data/input.bmp
```

Files in the Example
---------------------
```
	|   aes_decrypt.tcl					: Compilation Script
	|   build.sh
	|	CONTRIBUTING.md 
	|   Export_Compliance_Notice.md
	|   LICENSE.md
	|   README.md
	|   
	+---cmake
	|       FindOpenCL.cmake
	|       
	+---data
	|       input.bmp					: Test Data
	|       
	\---src
		|   aes_app.cpp
		|   aes_app.h
		|   aes_ecb.cpp
		|   aes_ecb.h
		|   krnl_aes.cl					: Kernel code
		|   main.cpp
		|   
		\---common
				cmdlineparser.cpp
				cmdlineparser.h
				logger.cpp
				logger.h
				simplebmp.cpp
				simplebmp.h
				xcl.cpp
				xcl.h
```
## SUPPORT
For questions and to get help on this project or your own projects, visit the [SDAccel Forums][]. 

## License
The source for this project is licensed under the [3-Clause BSD License][]

## Contributing code
Please refer to and read the [Contributing][] document for guidelines on how to contribute code to this open source project. The code in the `/master` branch is considered to be stable, and all pull-requests should be made against the `/develop` branch.

## Acknowledgements
This project is written by developers at [Xilinx](http://www.xilinx.com/) with other contributors listed below:


## REVISION HISTORY

Date		|	Readme Version	|	Revision Description
----------------|-----------------------|-------------------------
MAR2016		|	1.0		|	Initial Xilinx release




[Contributing]: CONTRIBUTING.md 
[3-Clause BSD License]: LICENSE.md
[SDAccel Forums]: https://forums.xilinx.com/t5/SDAccel/bd-p/SDx
[SDAccel User Guides]: http://www.xilinx.com/support/documentation-navigation/development-tools/software-development/sdaccel.html?resultsTablePreSelect=documenttype:SeeAll#documentation 
