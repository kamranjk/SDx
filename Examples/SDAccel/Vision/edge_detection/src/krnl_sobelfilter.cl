/*******************************************************************************
Vendor: Xilinx
Associated Filename: krnl_sobelfilter.cl
Purpose: SDAccel edge detection example
Revision History: January 29, 2016

*******************************************************************************
Copyright (c) 2016, Xilinx, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software 
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*******************************************************************************/

#ifdef __ECLIPSE__
#define kernel
#define global
#define __constant
#endif

//BGR
#define BLUE_COMP 0
#define GREEN_COMP 1
#define RED_COMP 2


typedef unsigned char		u8;
typedef unsigned short		u16;
typedef unsigned int		u32;
typedef			 char		i8;
typedef			 short		i16;
typedef			 int		i32;


inline u32 pack_from_bgr_to_rgba(global u8* in_pixels) {

	//convert from 24 bits BGR to packed 32 bits RGBA
	u32 pixel = 0;

	//r
	pixel = in_pixels[RED_COMP];
	pixel = pixel << 8;

	//g
	pixel = pixel | (in_pixels[GREEN_COMP]);
	pixel = pixel << 8;

	//b
	pixel = pixel | (in_pixels[BLUE_COMP]);
	pixel = pixel << 8;

	//alpha = full
	pixel = pixel | 0xFF;

	return pixel;
}


inline void unpack_from_rgba_to_bgr(u32 rgba, global u8* out_pixels) {

	rgba = rgba >> 8;

	//b
	out_pixels[BLUE_COMP] = (u8)(rgba & 0xFF);
	rgba = rgba >> 8;

	//g
	out_pixels[GREEN_COMP] = (u8)(rgba & 0xFF);
	rgba = rgba >> 8;

	//r
	out_pixels[RED_COMP] = (u8)(rgba & 0xFF);
}


__kernel
__attribute__ ((reqd_work_group_size(1,1,1)))
void krnl_sobel(global u8* in_pixels, int nchannels, int width, int height, global u8* out_pixels)
{
	//GX MASK ROW [1] = -1,  0,  1
	//GX MASK ROW [2] = -2,  0,  2
	//GX MASK ROW [3] = -1,  0,  1
	//GY MASK ROW [1] = -1, -2, -1
	//GY MASK ROW [2] =  0,  0,  0
	//GY MASK ROW [3] =  1,  2,  1

	//original sobel weights
	int GX[3][3] = {
			{-1, 0, 1},
			{-2, 0, 2},
			{-1, 0, 1}
	};

	int GY[3][3] = {
			{-1, -2, -1},
			{ 0, 0, 0},
			{ 1,  2,  1}
	};
	

	//Scharr weights
	/*
	int GX[3][3] = {
			{3, 0, -3},
			{10, 0, -10},
			{3, 0, -3}
	};

	int GY[3][3] = {
			{3, 10, 3},
			{ 0, 0, 0},
			{-3, -10, -3}
	};
	*/

	//internal frame format is:
	//1- BGR pixels
	//2- lower-left corner is origin

	int sum = 0;
	int sumx = 0;
	int sumy = 0;

	//loop over height and width
	for(int y=0; y < height; y++) {
		for(int x=0; x < width; x++) {

			//reset for this pixel
			sumx = 0;
			sumy = 0;

			//u32 rgba = pack_from_bgr_to_rgba(&in_pixels[current]);

			//check boundaries
			if(x == 0 || x == width - 1)
				sum = 0;
			else if(y == 0 || y == height - 1)
				sum = 0;
			else
			{
				//approximate the X gradient
				for(int i=-1; i<=1; i++) {
					for(int j=-1; j<=1; j++) {
						//use i offset for x
						//use j offset for y
						int dx = (x + i + (y + j) * width) * nchannels;
						u32 pdx = pack_from_bgr_to_rgba(&in_pixels[dx]);

						//perform convolution
						sumx += GX[i + 1][j + 1] * pdx;
					}
				}


				//approximate the Y gradient
				for(int i=-1; i<=1; i++) {
					for(int j=-1; j<=1; j++) {
						//use i offset for x
						//use j offset for y
						int dy = (x + i + (y + j) * width) * nchannels;
						u32 pdy = pack_from_bgr_to_rgba(&in_pixels[dy]);

						//perform convolution
						sumy += GY[i + 1][j + 1] * pdy;
					}
				}

				//sum
				sum = abs(sumx) + abs(sumy);

				//clamp
				if(sum > 255)
					sum = 255;
				if(sum < 0)
					sum = 0;
			}

			//store
			int current = (x + y * width) * nchannels;
			out_pixels[current] = 255 - (u8)(sum);
			out_pixels[current+1] = 255 - (u8)(sum);
			out_pixels[current+2] = 255 - (u8)(sum);
		}
	}

}


