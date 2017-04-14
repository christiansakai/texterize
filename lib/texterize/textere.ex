defmodule Texterize.Textere do
  require Logger

  alias Texterize.Utils
  alias XmlBuilder

  defstruct text_path: nil,
            image_path: nil,
            ratio: nil,
            final_width: nil,
            final_height: nil,
            out_path: nil,
            text: nil,
            image: nil,
            pixels: nil,
            text_elements: nil,
            svg: nil

  def construct_text_elements(
    data = %__MODULE__{
              text: text,
              ratio: ratio,
              image: %{
                width: width, 
                pixels: pixels
              }
           }) do
    Logger.debug "Constructing text elements..."

    flattened_pixels = pixels |> List.flatten
    cycle = Stream.cycle(text)

    text_elements = 
      Stream.zip(flattened_pixels, cycle)
      |> Enum.to_list
      |> Enum.reduce({1, []}, 
        fn {pixel, character}, {i, acc} ->
          x = rem(i, width)
          y = div(i, width)

          fill = Utils.to_hex(pixel)

          fill_opacity = case pixel do
            {_, _, _} -> 1.0
            {_, _, _, a} -> a
          end

          x_dst = x * ratio

          case {x, acc} do
            # If it is the first pixel encountered in a row,
            # create a new <text> element.
            {1, _acc} ->
              {i + 1, 
               [{:text, %{x: x_dst, 
                          y: y, 
                          fill: fill,
                          "fill-opacity": fill_opacity
                        }, character} | acc]}

            # If the current pixel match the fill color of
            # the previous pixel. Append the current character
            # to the body of the previous <text> element.
            {_x, [{:text, element = %{fill: ^fill}, text} | tail]} ->
              {i + 1, 
               [{:text, element, text <> character} | tail]}

            # If the current pixel is a different color,
            # create and append a new <text> element.
            {_x, _acc} ->
              {i + 1, 
               [{:text, %{x: x_dst, 
                          y: y, 
                          fill: fill,
                          "fill-opacity": fill_opacity
                        }, character} | acc]}
          end
        end
      )
      |> elem(1)
    
    %{data | text_elements: text_elements}
  end

  def construct_svg(
    data = %__MODULE__{
              text_elements: text_elements,
              ratio: ratio,
              final_width: final_width,
              final_height: final_height,
              image: %{
                width: width, 
                height: height
              }
           }) do
    Logger.debug("Constructing svg with #{length text_elements} " <>
                 "text elements...")

    svg = 
      {
        :svg,
        %{
          viewBox: "0 0 #{width * ratio} #{height}",
          xmlns: "http://www.w3.org/2000/svg",
          style: "font-family: 'Source Code Pro'; font-size: 1px; font-weight: 900;",
          width: final_width,
          height: final_height,
          "xml:space": "preserve"
        },
        text_elements
      }
      |> XmlBuilder.generate

    %{data | svg: svg}
  end
end
