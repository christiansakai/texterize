# Texterize

Fill your image with text! Inspired by Pete Corey's [article](http://www.east5th.co/blog/2017/02/13/build-your-own-code-poster-with-elixir/). Big thanks for [IrisVR](https://irisvr.com/) for letting me do this during the Hack Day!

This is an Elixir CLI tool to merge your text files together with a picture. This program will look for text files recursively in your provided directory path, use that text to create a new _svg_ format image based on the original _png_ format image you provide.

It is better if your original _png_ image is small, just like in the example. As a perspective, my image is only `65 Kb`, but the produced _svg_ output was `4.4 Mb`. However, since this is _svg_ I can just open it using software like Photoshop/Illustrator and it the text will be rendered crisp, and I can print it if I want to.

In general, I think a size around `50 Kb` is best. Make sure your `text` source folder does not contain hidden files that contains odd characters.

__Dependencies__:
* [Elixir 1.4](http://elixir-lang.org/)
* [ImageMagick](https://www.imagemagick.org/script/index.php)
* [Adobe Source Code Pro Font](https://github.com/adobe-fonts/source-code-pro)

__Usage__:
* `git clone` this project
* `cd texterize`
* `./texterize`

__Example__:

See `example` folder for an example. I used this app's source code as the text for the image. You can run it using this command below.

```sh
./texterize -t ./lib -i ./example/image/christian.png -o ./example/output/christian.svg
```

