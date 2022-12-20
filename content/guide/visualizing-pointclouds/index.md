---
title: "Visualizing Point Clouds"
date: 2022-05-16
categories: 
  - astrophysics
  - data visualisation
author: Lukas Winkler
cc_license: true
description: "A few ways to interactively display point clouds in 3D"
---

Assuming you have a dataset of particles (e.g. dark matter particles in cosmological simulation, SPH-particles, etc.) and their coordinates, there are multiple ways to browse through them as a 3D point cloud.

<!--more-->

## Using Paraview

The most interactive method is using [Paraview](https://www.paraview.org/). It can read many input formats, but for simplicity we are using CSV files with columns for X, Y and Z coordinates here.

{{<image src="csv.png" >}}

After opening the CSV with the right delimiter we get a SpreadSheetView displaying the data.

{{<image src="csv2.png" >}}

To now draw points for all particles, we go back to the default RenderView and select Filters -> Alphabetical -> Table to Points. First we need to assign the columns to the dimensions before clicking on "Apply".

{{<image src="columns.png" >}}

If you don't see any points, check if you have focused the RenderView and the eye symbol in the Pipeline Browser is enabled. If the particles are not centered or very small (e.g. because of accidentally plotting the particle ID as a dimension before), one can open the "Adjust Camera" menu of the RenderView and select a Standard Viewpoint.


{{<image src="cloud1.png" >}}

If your dataset has an additional column, you can color the points according to it by selecting it in the "Coloring" section. The used colormap can be edited to e.g. use logarithmic values.

As a next step, reducing the opacity allows us to better see the distribution of the particle density. Depending on the number of particles a very low value can be used (e.g. 0.02 here for 2 million particles).

{{<image src="cloud2.png" >}}

Still areas with high density are just white blobs and the level of detail depends on the zoom level as the size of the points is always the same.


{{<video src_webm="video1.webm" src_mp4="video1.mp4" loop="true" >}}


One solution to this problem is to use Point Gaussians instead of points to represent every particle. For this select "Point Gaussian" from the "Representation" drop-down. In the new "Point Gaussian" you can then change the shader preset. While "Sphere" might work with a small amount of large masses, representing them as a "Gaussian Blur" works best for large amounts of particles.

{{<image src="cloud3.png" >}}

If you see triangle-like structures, try changing the opacity. Once again we need to set the Gaussian Radius to a very low value until all details can be differentiated.

{{<image src="cloud4.png" >}}


{{<video src_webm="video2.webm" src_mp4="video2.mp4" loop="true" >}}


{{<video src_webm="video3.webm" src_mp4="video3.mp4" loop="true" >}}

## In Python

While Paraview is very powerful, often it is useful to display a subset of data automatically during data analysis without needing to export and open the dataset every time. Therefore, it is useful to create the same visualisation in Python.

For this we are using [vtk](https://vtk.org/) which Paraview is based on. As the [Python VTK wrapper](https://vtk.org/doc/nightly/html/md__builds_gitlab_kitware_sciviz_ci_Documentation_Doxygen_PythonWrappers.html) is not always very user-friendly, the best solution is [pyvista](pyvista.org), which abstracts many of [these details](https://docs.pyvista.org/examples/00-load/create-point-cloud.html) away.

```bash
➜ pip install pyvista
# if you are using python3.10, you might need to read
# https://github.com/pyvista/pyvista/discussions/2064
```

Let's assume `data` is a numpy array with three columns corresponding to the position of the particles (similar to the output of `np.random.random((1000, 3))`).

Then we can initialize a pyvista Plotter like this:

```python
from pyvista import Plotter

pl = Plotter()
```

Next we need to convert the data to a `PointSet`:

```python
pdata = pyvista.PointSet(data)
# data[::, 0:3] if there are more than three columns

```

Then we can plot the data:
```python
pl.add_mesh(
    pdata,
    point_size=1,
    style="points",
    opacity=0.1,
    color="white",
    # scalars=data[::, -1], # if we had a column with values
)
pl.enable_parallel_projection()
```
Instead of specifying `style="points"` explicitly, we could also use `pl.add_points()` directly.
Once again `point_size` and `opacity` can be adapted to the dataset.

Finally, we can open the window using 
```
pl.show()
```


{{<image src="pyvista1.png" >}}

If we know the center of the object, we can manually specify it using
```python
pl.set_focus((halo.X, halo.Y, halo.Z))
```

Also a grid can be added:

```python
pl.show_grid()
```

{{<image src="pyvista2.png" >}}

And optionally the output can be rendered in 3d:
```python
pl.enable_stereo_render()
# use one of the many SetStereoTypeTo*() functions
pl.ren_win.SetStereoTypeToSplitViewportHorizontal()
pl.ren_win.SetStereoTypeToAnaglyph()
```

A regular graphics card should be able to display millions of points in real-time without dropping any frames. 

{{<video src_webm="video4.webm" src_mp4="video4.mp4" loop="true" >}}


The major limitation of this visualisation is that it doesn't seem possible to use Point Gaussians as above using Paraview. You can read more about this [here](https://github.com/pyvista/pyvista/discussions/2576).


## Bonus: Exporting Videos for Publication
{{<video src_webm="high_res1.webm" src_mp4="high_res1.mp4"  >}}
{{<video src_webm="high_res2.webm" src_mp4="high_res2.mp4"  >}}


Exporting Videos in Paraview and similar tools is rather easy, but the options are often quite limited and only support older formats and codecs. Therefore, the resulting videos can often be quite large and in low quality which is especially bad for point clouds where a lot of fine details can be lost in video compression.

Because of this it is often useful to export the video as a collection of (losslessly compressed) PNG files and [encode the video](https://gist.github.com/Vestride/278e13915894821e1d6f) yourself.

The following options are optimized for a high quality while still having a small file size, which means they can be slow to encode. But as most videos are rather short, this should not be that important. Also, the videos on this page are compressed more to keep the loading time small while loosing only little quality.

### VP9

[VP9](https://en.wikipedia.org/wiki/VP9) is a widely supported modern video codec. 

For the best results a two-pass encoding is used with the first command saving a temporary file and the second command actually encoding the file.

```bash
➜ ffmpeg -framerate 30 -i img.%04d.png -c:v libvpx-vp9 -pass 1 -b:v 3M  -speed 4 -tile-columns 6 -frame-parallel 1 -an -pix_fmt yuv420p -f webm -y /dev/null
```
```bash
➜ ffmpeg -framerate 30 -i img.%04d.png -c:v libvpx-vp9 -pass 2 -b:v 3M  -speed 1 -tile-columns 6 -frame-parallel 1 -auto-alt-ref 1 -lag-in-frames 25 -pix_fmt yuv420p -f webm -y out.webm
```

Important options:
- `-framerate`: set to the amount of frames per second
- `-i img.%04d.png`: this assumes the images are called `img.0001.png`
- `-b:v 3M`: this is the main parameter to change to influence the file size and quality. It specifies the bitrate (so 3 MB/s here). Simple videos might already look great with 1 MB/s while videos with a lot of moving small parts might need a lot more here. Alternatively you can specify a CRF as explained below with `-crf` (a value around 10 might be a good start). 
- `-pix_fmt yuv420p`: [chroma subsampling](https://en.wikipedia.org/wiki/Chroma_subsampling) for compression and support in browsers
- `-y`: answer "yes" when asked to overwrite existing files
- `out.webm` use WebM as a container format for the output file


You might also want to add [`-row-mt 1`](https://groups.google.com/a/webmproject.org/g/codec-devel/c/oiHjgEdii2U) for more parallelisation if you have many CPU cores.

More information about the options can be found [here](https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide).

### MP4 (H.264)

Some browsers don't support VP9 yet (most notably Safari), so a fallback to MP4 might be useful as it is supported on most devices:

Here, instead of constraining the bitrate, we use a Constant Rate Factor (CRF) to specify the quality. 
It can go from 0 to 51 with a lower value indicating a higher quality. Values around 20 might be a good starting range. 

```bash
➜ ffmpeg -framerate 30 -i img.%04d.png -vcodec h264 -b:v 1M -strict -2 -pix_fmt yuv420p -preset veryslow -crf 20 -movflags +faststart -y out.mp4
```

### Display in browsers

You can use the `<video>` tag to embed videos in websites.

For gif-like looping videos:
```html
<video autoplay loop muted controls playsinline>
    <source src="video.webm" type="video/webm; codecs=vp9">
    <source src="video.mp4" type="video/mp4">
</video>
```

For regular videos (only load the metadata/thumbnail until pressing play):
```html
<video preload="metadata" muted controls playsinline>
    <source src="video.webm" type="video/webm; codecs=vp9">
    <source src="video.mp4" type="video/mp4">
</video>
```
