rem LKB(c) 2012
rem use on the Matlab output to make it transparent,chop whitespace and resize
@echo off

FOR /f %%F IN ('dir /b *.png *.jpg *.bmp') DO (
echo converting %%F

	mv %%F old_%%F
	rem remove white ; resize to x1600 only if bigger; transparent
	"d:\Utils\ImageMagick\convert.exe" old_%%F -trim -resize "x1600>" -transparent white %%~nF.png
	mv old_%%F SS\%%F
	rem can also use -resize 75%%
	
echo 		.........done
echo.
)
echo.
echo AND NOW NEW APPROACH
rem 	 ls *.png | cut -d. -f1 | xargs -r -I FILE convert FILE.png -background white -flatten -resize "x1600>" -trim FILE.jpg
rem 	ls *.jpg | cut -d. -f1 | xargs -r -I FILE convert FILE.jpg -resize "x1600>" -trim FILE.jpg
echo ALL DONE

rem ls *.jpg | cut -d. -f1 | xargs -r -I FILE "d:\Utils\ImageMagick\convert.exe" FILE.jpg -resize "x1600>" -trim FILE.jpg