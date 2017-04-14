defmodule Texterize do
  require Logger

  alias Texterize.Utils
  alias Texterize.Textere

  def run,
    do: run(0.6, 
            3000, 3000, 
            "./assets/code", 
            "./assets/image/logo.png",
            "./assets/output/logo.svg")

  def main(args \\ []) do
    {opts, _, _} = 
      args
      |> OptionParser.parse(
        switches: [text: :string,
                   image: :string,
                   output: :string],
        aliases: [t: :text,
                  i: :image,
                  o: :output])

    if !opts[:text] ||
       !opts[:image] ||
       !opts[:output] do
      IO.puts """

      Example usage: 
      ./texterize -t ./assets/code -i ./assets/image/image.png -i ./assets/output/image.svg

        -t  path to directory where the text files reside
        -i  path to image
        -o  path to directory where the output will be produced
        """
    else
      run(0.6, 3000, 3000,
          opts[:text], opts[:image], opts[:output])
    end
  end


  defp get_text(text_path) do
    text_path
    |> Utils.search_files
    |> Utils.load_text
    |> Utils.clean_text
    |> String.codepoints
  end

  defp get_image(image_path, ratio) do
    image_path
    |> Utils.get_image_dimensions
    |> Utils.scale_image(ratio, image_path)
    |> Utils.load_image
  end

  def run(ratio,
          final_width,
          final_height,
          text_path,
          image_path,
          out_path) do

    text = get_text(text_path)
    image = get_image(image_path, ratio)

    %Textere{
      ratio: ratio,
      final_width: final_width,
      final_height: final_height,
      text_path: text_path,
      image_path: image_path,
      out_path: out_path,
      text: text,
      image: image
    }
    |> Textere.construct_text_elements
    |> Textere.construct_svg
    |> Map.get(:svg)
    |> Utils.save_image(out_path)
  end
end
