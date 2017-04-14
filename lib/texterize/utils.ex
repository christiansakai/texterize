defmodule Texterize.Utils do
  require Logger

  @doc """
  iex> Texterize.Utils.to_hex {50, 150, 250}
  "#3296FA"
  iex> Texterize.Utils.to_hex {255, 0, 128}
  "#FF0080"
  iex> Texterize.Utils.to_hex {50, 150, 250, 0}
  "#3296FA"
  iex> Texterize.Utils.to_hex {255, 0, 128, 0}
  "#FF0080"
  """
  def to_hex({r, g, b}) do
    "#" <>
    (r |> :binary.encode_unsigned |> Base.encode16) <>
    (g |> :binary.encode_unsigned |> Base.encode16) <>
    (b |> :binary.encode_unsigned |> Base.encode16)
  end

  def to_hex({r, g, b, _}) do
    to_hex({r, g, b})
  end

  def load_text(paths) do
    paths
    |> Enum.map(fn path -> 
      Logger.debug "Loading text from '#{path}'..."

      File.read!(path)
    end)
    |> Enum.join(" ")
  end

  def search_files(path) do
    if File.dir?(path) == false do
      path
    else
      File.ls!(path)
      |> Enum.map(fn sub_path ->
        search_files("#{path}/#{sub_path}")
      end)
      |> List.flatten
    end
  end

  @doc """
  iex> Texterize.Utils.clean_code("if (true) {\\nbang;\\n}")
  "if (true) { bang; }"
  iex> Texterize.Utils.clean_code("{\\n'    ';\\n}")
  "{ '    '; }"
  iex> Texterize.Utils.clean_code("a\\nbb\\n\\tc\\nd")
  "a bb c d"
  """
  def clean_text(text) do
    Logger.debug "Cleaning text..."
    
    text
    |> String.trim
    |> String.replace(~r/\s*\n+\s*/, " ")
    |> String.replace(~r/\s/," ")
  end

  def get_image_dimensions(image_path) do
    Logger.debug "Getting image dimensions from '#{image_path}'..."

    {:ok, %{width: width, height: height}} = Imagineer.load(image_path)
    {width, height}
  end

  def scale_image({width, height}, ratio, image_path) do
    new_size = "#{round(width * (1 / ratio))}x#{height}!"

    %Mogrify.Image{path: path} = 
      image_path
      |> Mogrify.open
      |> Mogrify.resize(new_size)
      |> Mogrify.save

    Logger.debug "Created temporary scaled image on '#{path}'..."
    path
  end
  
  def load_image(path) do
    Logger.debug "Loading image from '#{path}'..."

    {:ok, image} = Imagineer.load(path)
    image
  end

  def save_image(svg, path) do
    Logger.debug "Saving svg to '#{path}'..."

    {:ok, file} = File.open(path, [:write])
    IO.binwrite(file, svg)
    File.close(file)
  end

end
